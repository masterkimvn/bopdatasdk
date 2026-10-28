import { useEffect, useState } from 'react';
import { BopDataClient } from 'bop-data-sdk-local';

export function Dataset({ canonicalId }) {
  const [state, setState] = useState({ loading: true });
  useEffect(() => {
    let active = true;
    setState({ loading: true });
    new BopDataClient().getDataset(canonicalId)
      .then(dataset => { if (active) setState({ dataset }); })
      .catch(error => { if (active) setState({ error: error.message }); });
    return () => { active = false; };
  }, [canonicalId]);
  if (state.loading) return <p>Loading dataset…</p>;
  if (state.error) return <p>Unable to load dataset: {state.error}</p>;
  return <pre>{JSON.stringify({ data: state.dataset.data, freshness: state.dataset.freshness, provenance: state.dataset.provenance }, null, 2)}</pre>;
}
