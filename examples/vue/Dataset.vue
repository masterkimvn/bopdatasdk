<script setup>
import { ref, watch } from 'vue';
import { BopDataClient } from 'bop-data-sdk-local';
const props = defineProps({ canonicalId: { type: String, required: true } });
const dataset = ref(null), error = ref(''), loading = ref(true);
watch(() => props.canonicalId, async (id, _old, onCleanup) => {
  let active = true;
  onCleanup(() => { active = false; });
  loading.value = true; error.value = ''; dataset.value = null;
  try { const result = await new BopDataClient().getDataset(id); if (active) dataset.value = result; }
  catch (e) { if (active) error.value = e.message; }
  finally { if (active) loading.value = false; }
}, { immediate: true });
</script>
<template>
  <p v-if="loading">Loading dataset…</p>
  <p v-else-if="error">Unable to load dataset: {{ error }}</p>
  <pre v-else>{{ JSON.stringify({ data: dataset.data, freshness: dataset.freshness, provenance: dataset.provenance }, null, 2) }}</pre>
</template>
