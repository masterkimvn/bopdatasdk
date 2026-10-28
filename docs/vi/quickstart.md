# Bắt đầu với BOP Data SDK

**BOP Data** ([data.bop.ink](https://data.bop.ink)) là nguồn dataset có cấu trúc công khai, phi lợi nhuận và không quảng cáo. **BOP Data SDK** là cầu nối kỹ thuật giúp website, ứng dụng, phần mềm và AI lấy dữ liệu trực tiếp từ API của BOP Data.

**Phiên bản GitHub:** [v1.0.0](https://github.com/masterkimvn/bopdatasdk/releases/tag/v1.0.0) (source code). Repository chứa 11 client: JavaScript/TypeScript, Python, PHP, Go, Java, C#/.NET, Rust, Ruby, Kotlin, Swift và Dart. **Các package chưa được phát hành lên registry**, tên và phiên bản package local có thể khác với version GitHub.

## Lấy dữ liệu thật

```bash
curl -fsS https://data.bop.ink/api/v1/datasets.json
```

Đọc catalog để lấy `canonicalId`, sau đó truy xuất JSON hoặc CSV:

```text
https://data.bop.ink/api/v1/datasets/{canonicalId}.json
https://data.bop.ink/api/v1/datasets/{canonicalId}.csv
```

Xem [hướng dẫn sử dụng tất cả client](../clients.md) và [ví dụ chạy từ mã nguồn](../examples.md).

SDK chỉ giúp **gọi API → nhận dữ liệu → trả về ứng dụng**, không tự kiểm định tính đúng sai của dataset. Trên trình duyệt, khả năng gọi trực tiếp phụ thuộc chính sách CORS của BOP Data; mobile native không chịu browser CORS theo cách tương tự.

Khi sử dụng dữ liệu, vui lòng ghi nhận nguồn **BOP Data** (không bắt buộc gắn liên kết cho lời ghi nhận đơn giản này). Riêng điều khoản, giấy phép và nghĩa vụ ghi công của từng dataset hoặc nguồn gốc vẫn cần được tuân thủ. Giấy phép mã nguồn SDK chưa được xác nhận, nên không mặc định quyền tái phân phối chỉ vì code public.

**Người sáng lập:** Phạm Hoàng Đức (Master Kim) — [about.bop.ink](https://about.bop.ink).


## Phát hành package

Các package đã được chuẩn bị tên và metadata để đăng lên từng kho phần mềm, nhưng **chưa xác nhận đã xuất bản thực tế**. Xem [trạng thái phân phối](../registry-status.md). Mã nguồn SDK dùng MIT; giấy phép dataset độc lập.
