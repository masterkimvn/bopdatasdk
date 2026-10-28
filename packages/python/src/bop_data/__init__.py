"""Read-only BOP Data client."""
import json
import re
import socket
from typing import Any, Optional
from urllib.parse import quote, urlsplit
from urllib.error import HTTPError, URLError
from urllib.request import build_opener, HTTPRedirectHandler, Request

class _NoRedirect(HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        return None

class BopDataError(Exception):
    def __init__(self, kind: str, message: str, status: Optional[int] = None):
        super().__init__(message)
        self.kind, self.status = kind, status

class BopDataClient:
    def __init__(self, base_url: str = 'https://data.bop.ink', timeout: float = 10):
        u = urlsplit(base_url)
        if u.scheme not in ('http', 'https') or not u.hostname or u.username or u.password or u.query or u.fragment or timeout <= 0:
            raise ValueError('Invalid client configuration')
        self.base_url, self.timeout = base_url.rstrip('/'), timeout

    def _request(self, path: str, spec: Optional[str] = None) -> Any:
        try:
            with build_opener(_NoRedirect()).open(Request(self.base_url + path, headers={'User-Agent': 'BOPDataSDK/0.1'}), timeout=self.timeout) as response:
                body = response.read()
        except HTTPError as e:
            raise BopDataError('http', f'HTTP {e.code}', e.code) from None
        except (URLError, OSError) as e:
            kind = 'timeout' if isinstance(e, (TimeoutError, socket.timeout)) or isinstance(getattr(e, 'reason', None), (TimeoutError, socket.timeout)) else 'transport'
            raise BopDataError(kind, 'Request failed') from None
        if spec is None:
            return body.decode('utf-8')
        try:
            value = json.loads(body)
        except (ValueError, UnicodeDecodeError):
            raise BopDataError('json', 'Invalid JSON response') from None
        if not isinstance(value, dict) or value.get('spec') != spec:
            raise BopDataError('spec', 'Incompatible response spec')
        return value

    @staticmethod
    def _id(value: str) -> str:
        if not isinstance(value, str) or not re.fullmatch(r'[A-Za-z0-9._-]{3,}', value):
            raise BopDataError('invalid_id', 'Invalid canonical ID')
        return quote(value, safe='')

    def list_datasets(self) -> dict[str, Any]:
        return self._request('/api/v1/datasets.json', 'bop.catalog/1')
    def get_dataset(self, canonical_id: str) -> dict[str, Any]:
        return self._request('/api/v1/datasets/' + self._id(canonical_id) + '.json', 'bop.dataset/1')
    def get_dataset_csv(self, canonical_id: str) -> str:
        return self._request('/api/v1/datasets/' + self._id(canonical_id) + '.csv')
