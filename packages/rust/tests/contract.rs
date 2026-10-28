use bop_data_sdk::{Client, Error};
use std::{
    io::{Read, Write},
    net::TcpListener,
    thread,
    time::Duration,
};
#[test]
fn contract() {
    let listener = TcpListener::bind("127.0.0.1:0").unwrap();
    let address = listener.local_addr().unwrap();
    let server = thread::spawn(move || {
        for _ in 0..4 {
            let (mut stream, _) = listener.accept().unwrap();
            let mut buf = [0; 4096];
            let n = stream.read(&mut buf).unwrap();
            let req = String::from_utf8_lossy(&buf[..n]);
            let (status, body) = if req.contains("missing") {
                (404, vec![])
            } else if req.contains(".csv") {
                (200, b"\xef\xbb\xbfa,b\r\n".to_vec())
            } else if req.contains("datasets.json") {
                (200, include_bytes!("fixtures/catalog.json").to_vec())
            } else {
                (200, include_bytes!("fixtures/dataset.json").to_vec())
            };
            write!(
                stream,
                "HTTP/1.1 {} OK\r\nContent-Length: {}\r\nConnection: close\r\n\r\n",
                status,
                body.len()
            )
            .unwrap();
            stream.write_all(&body).unwrap();
        }
    });
    let c = Client::new(&format!("http://{}", address), Duration::from_secs(2)).unwrap();
    assert_eq!(c.list_datasets().unwrap()["total"], 2);
    let d = c.get_dataset("test.one").unwrap();
    assert_eq!(d["future"], "preserved");
    assert_eq!(d["provenance"]["license"], "synthetic");
    assert!(d["freshness"]["lastUpdated"].is_null());
    assert!(c
        .get_dataset_csv("test.one")
        .unwrap()
        .starts_with(b"\xef\xbb\xbf"));
    assert!(matches!(c.get_dataset("missing"), Err(Error::Http(404))));
    for id in ["", "a/b", "abc\n", "đxx"] {
        assert!(matches!(c.get_dataset(id), Err(Error::InvalidId)));
    }
    server.join().unwrap();
}
