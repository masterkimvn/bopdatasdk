export interface Catalog { spec: 'bop.catalog/1'; total: number; datasets: CatalogEntry[]; [key: string]: unknown }
export interface CatalogEntry { canonicalId: string; links?: Record<string, string>; [key: string]: unknown }
export interface Dataset { spec: 'bop.dataset/1'; canonicalId: string; identity: Record<string, unknown>; data: Record<string, unknown>; freshness: Record<string, unknown>; provenance: Record<string, unknown>; links: Record<string, unknown>; [key: string]: unknown }
export class BopDataError extends Error { kind: string; status?: number; }
export class BopDataClient {
 constructor(options?: {baseUrl?: string; timeoutMs?: number; fetch?: typeof fetch});
 listDatasets(): Promise<Catalog>; getDataset(id: string): Promise<Dataset>; getDatasetCsv(id: string): Promise<string>;
}
