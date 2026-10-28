//! Read-only client for BOP Data.
use reqwest::{blocking::Client as HttpClient, redirect::Policy, Url};
use serde_json::Value;
use std::{fmt, io::Read, time::Duration};

#[derive(Debug)]
pub enum Error {
    InvalidConfig,
    InvalidId,
    Http(u16),
    Transport,
    Timeout,
    TooLarge,
    Json,
    Spec,
}
impl fmt::Display for Error {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{:?}", self)
    }
}
impl std::error::Error for Error {}
pub struct Client {
    base: String,
    http: HttpClient,
    max_bytes: u64,
}
impl Client {
    pub fn new(base: &str, timeout: Duration) -> Result<Self, Error> {
        let url = Url::parse(base).map_err(|_| Error::InvalidConfig)?;
        if !["http", "https"].contains(&url.scheme())
            || url.host_str().is_none()
            || !url.username().is_empty()
            || url.password().is_some()
            || url.query().is_some()
            || url.fragment().is_some()
            || timeout.is_zero()
        {
            return Err(Error::InvalidConfig);
        }
        let http = HttpClient::builder()
            .redirect(Policy::none())
            .timeout(timeout)
            .user_agent("BOPDataSDK/0.1")
            .build()
            .map_err(|_| Error::InvalidConfig)?;
        Ok(Self {
            base: base.trim_end_matches('/').to_owned(),
            http,
            max_bytes: 8_000_000,
        })
    }
    fn id(id: &str) -> Result<&str, Error> {
        if id.len() < 3
            || !id
                .bytes()
                .all(|b| b.is_ascii_alphanumeric() || b"._-".contains(&b))
        {
            return Err(Error::InvalidId);
        }
        Ok(id)
    }
    fn get(&self, path: &str) -> Result<Vec<u8>, Error> {
        let response = self
            .http
            .get(format!("{}{}", self.base, path))
            .send()
            .map_err(|e| {
                if e.is_timeout() {
                    Error::Timeout
                } else {
                    Error::Transport
                }
            })?;
        if !response.status().is_success() {
            return Err(Error::Http(response.status().as_u16()));
        }
        let mut data = Vec::new();
        response
            .take(self.max_bytes + 1)
            .read_to_end(&mut data)
            .map_err(|_| Error::Transport)?;
        if data.len() as u64 > self.max_bytes {
            return Err(Error::TooLarge);
        }
        Ok(data)
    }
    fn json(&self, path: &str, spec: &str) -> Result<Value, Error> {
        let value: Value = serde_json::from_slice(&self.get(path)?).map_err(|_| Error::Json)?;
        if value.get("spec").and_then(Value::as_str) != Some(spec) {
            return Err(Error::Spec);
        }
        Ok(value)
    }
    pub fn list_datasets(&self) -> Result<Value, Error> {
        self.json("/api/v1/datasets.json", "bop.catalog/1")
    }
    pub fn get_dataset(&self, id: &str) -> Result<Value, Error> {
        self.json(
            &format!("/api/v1/datasets/{}.json", Self::id(id)?),
            "bop.dataset/1",
        )
    }
    pub fn get_dataset_csv(&self, id: &str) -> Result<Vec<u8>, Error> {
        self.get(&format!("/api/v1/datasets/{}.csv", Self::id(id)?))
    }
}
impl Default for Client {
    fn default() -> Self {
        Self::new("https://data.bop.ink", Duration::from_secs(10)).expect("default client")
    }
}
