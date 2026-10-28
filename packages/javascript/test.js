import {test} from 'node:test'; import assert from 'node:assert/strict'; import {readFile} from 'node:fs/promises'; import {BopDataClient} from './index.js';
const catalog = await readFile(new URL('../../tests/fixtures/catalog.json', import.meta.url),'utf8'); const dataset = await readFile(new URL('../../tests/fixtures/dataset.json', import.meta.url),'utf8');
test('contract and errors', async () => {
 const c = new BopDataClient({fetch: async u => new Response(u.endsWith('datasets.json') ? catalog : u.endsWith('.csv') ? '\ufeffa,"b"\r\n' : dataset)});
 assert.equal((await c.listDatasets()).total,2); assert.equal((await c.getDataset('test.one')).future,'preserved'); assert.equal(await c.getDatasetCsv('test.one'),'\ufeffa,"b"\r\n');
 for(const id of ['', 'a/b', 'https://x', 'đxx', 'abc\n']) assert.throws(()=>c.getDataset(id));
 for(const status of [404,429,503]) { const x=new BopDataClient({fetch:async()=>new Response('',{status})}); await assert.rejects(x.listDatasets(),e=>e.status===status); }
 for(const body of ['{','{"spec":"wrong"}']) { const x=new BopDataClient({fetch:async()=>new Response(body)}); await assert.rejects(x.listDatasets()); }
});
test('timeout and metadata', async () => {
 const client = new BopDataClient({timeoutMs: 10, fetch: (_u, {signal}) => new Promise((_resolve, reject) => signal.addEventListener('abort', () => reject(new Error('abort'))))});
 await assert.rejects(client.listDatasets(), e => e.kind === 'timeout');
 const c = new BopDataClient({fetch: async () => new Response(dataset)}); const d = await c.getDataset('test.one');
 assert.equal(d.freshness.lastUpdated, null); assert.equal(d.provenance.license, 'synthetic');
});
test('timeout while reading response body', async () => {
 const client = new BopDataClient({timeoutMs:10, fetch: async (_url, {signal}) => ({ok:true, arrayBuffer: () => new Promise((_resolve, reject) => signal.addEventListener('abort', () => reject(new Error('aborted'))))})});
 await assert.rejects(client.getDatasetCsv('test.one'), e => e.kind === 'timeout');
});
