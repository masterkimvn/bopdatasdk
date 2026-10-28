export type Envelope = { spec: string; [key: string]: unknown };
export class BopDataError extends Error { kind: string; status?: number; }
export class BopDataClient {
 constructor(options?: {baseUrl?: string; timeoutMs?: number; fetch?: typeof fetch});
 listDatasets(): Promise<Envelope>; getDataset(id: string): Promise<Envelope>; getDatasetCsv(id: string): Promise<string>;
}
