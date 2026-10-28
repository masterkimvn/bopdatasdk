import json, pathlib, threading, unittest
from http.server import BaseHTTPRequestHandler, HTTPServer
from bop_data import BopDataClient, BopDataError
fixtures = pathlib.Path(__file__).resolve().parents[2] / 'tests' / 'fixtures'
class Handler(BaseHTTPRequestHandler):
 def do_GET(self):
  for code in (404, 429, 503):
   if f'status{code}' in self.path or (code == 404 and 'missing' in self.path): self.send_response(code); self.end_headers(); return
  if 'slow' in self.path:
   import time; time.sleep(.3); return
  if 'invalid' in self.path or 'wrong' in self.path:
   self.send_response(200); self.end_headers(); self.wfile.write(b'{' if 'invalid' in self.path else b'{"spec":"wrong"}'); return
  self.send_response(200); self.end_headers()
  if self.path.endswith('.csv'): self.wfile.write(b'\xef\xbb\xbfa,b\r\n'); return
  self.wfile.write((fixtures / ('catalog.json' if self.path.endswith('datasets.json') else 'dataset.json')).read_bytes())
 def log_message(self,*args): pass
class Contract(unittest.TestCase):
 @classmethod
 def setUpClass(cls):
  cls.server=HTTPServer(('127.0.0.1',0),Handler); threading.Thread(target=cls.server.serve_forever,daemon=True).start(); cls.client=BopDataClient('http://127.0.0.1:'+str(cls.server.server_port))
 @classmethod
 def tearDownClass(cls): cls.server.shutdown(); cls.server.server_close()
 def test_contract(self):
  self.assertEqual(self.client.list_datasets()['total'],2); self.assertEqual(self.client.get_dataset('test.one')['future'],'preserved'); self.assertTrue(self.client.get_dataset_csv('test.one').startswith('\ufeff'))
  for value in ('','a/b','https://x','đxx'):
   with self.assertRaises(BopDataError): self.client.get_dataset(value)
  with self.assertRaises(BopDataError) as e: self.client.get_dataset('missing')
  self.assertEqual(e.exception.status,404)
  for code in (429,503):
   with self.assertRaises(BopDataError) as e: self.client.get_dataset('status'+str(code))
   self.assertEqual(e.exception.status,code)
  for name, kind in (('invalid','json'),('wrong','spec')):
   with self.assertRaises(BopDataError) as e: self.client.get_dataset(name)
   self.assertEqual(e.exception.kind,kind)
  with self.assertRaises(BopDataError) as e: BopDataClient(self.client.base_url, .03).get_dataset('slow')
  self.assertEqual(e.exception.kind,'timeout')
if __name__ == '__main__': unittest.main()
