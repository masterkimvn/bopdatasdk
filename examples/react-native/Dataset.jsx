import React, { useEffect, useState } from 'react';
import { ActivityIndicator, ScrollView, Text } from 'react-native';
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
  if (state.loading) return <ActivityIndicator />;
  if (state.error) return <Text>Unable to load dataset: {state.error}</Text>;
  return <ScrollView><Text>{JSON.stringify({data: state.dataset.data, freshness: state.dataset.freshness, provenance: state.dataset.provenance}, null, 2)}</Text></ScrollView>;
}
