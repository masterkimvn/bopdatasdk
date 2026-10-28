export class BopDataError extends Error {
  constructor(kind, message, status) { super(message); this.name = 'BopDataError'; this.kind = kind; this.status = status; }
}
export class BopDataClient {
  constructor({baseUrl = 'https://data.bop.ink', timeoutMs = 10000, fetch: transport = globalThis.fetch} = {}) {
    const u = new URL(baseUrl);
    if (!['https:', 'http:'].includes(u.protocol) || u.username || u.password || u.search || u.hash) throw new TypeError('Invalid base URL');
    if (!Number.isFinite(timeoutMs) || timeoutMs <= 0 || typeof transport !== 'function') throw new TypeError('Invalid client configuration');
    this.baseUrl = u.href.replace(/\/$/, ''); this.timeoutMs = timeoutMs; this.fetch = transport;
  }
  async request(path, spec) {
    const controller = new AbortController(); const timer = setTimeout(() => controller.abort(), this.timeoutMs);
    try {
      let response;
      try { response = await this.fetch(this.baseUrl + path, {signal: controller.signal, credentials: 'omit', redirect: 'error'}); }
      catch (e) { throw new BopDataError(controller.signal.aborted ? 'timeout' : 'transport', 'Request failed'); }
      if (!response.ok) throw new BopDataError('http', `HTTP ${response.status}`, response.status);
      let bytes;
      try { bytes = await response.arrayBuffer(); } catch { throw new BopDataError(controller.signal.aborted ? 'timeout' : 'transport', 'Request failed'); }
      if (!spec) return new TextDecoder('utf-8', {ignoreBOM: true}).decode(bytes);
      let result; try { result = JSON.parse(new TextDecoder('utf-8', {fatal: true}).decode(bytes)); } catch { throw new BopDataError('json', 'Invalid JSON response'); }
      if (!result || typeof result !== 'object' || result.spec !== spec) throw new BopDataError('spec', 'Incompatible response spec');
      return result;
    } finally { clearTimeout(timer); }
  }
  id(id) { if (typeof id !== 'string' || !(/^[A-Za-z0-9._-]{3,}$/.test(id) && !/[\r\n]/.test(id))) throw new BopDataError('invalid_id', 'Invalid canonical ID'); return encodeURIComponent(id); }
  listDatasets() { return this.request('/api/v1/datasets.json', 'bop.catalog/1'); }
  getDataset(id) { return this.request(`/api/v1/datasets/${this.id(id)}.json`, 'bop.dataset/1'); }
  getDatasetCsv(id) { return this.request(`/api/v1/datasets/${this.id(id)}.csv`); }
}
