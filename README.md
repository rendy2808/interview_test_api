# Take Home Test

## Goals

1. **Implementasikan Unit Test**
   - Buatlah unit test yang komprehensif untuk memastikan semua fungsi dalam proyek ini bekerja seperti yang diharapkan.
   - Pastikan semua tes berjalan dengan baik dan mencapai tingkat cakupan yang memadai.

2. **Implementasikan Caching** (Optional)
   - Tambahkan mekanisme caching untuk meningkatkan performa aplikasi.
   - Pastikan bahwa sistem caching berfungsi dengan baik dan tidak mengganggu logika utama aplikasi.

## Poin Penilaian

Ketika menyelesaikan tugas ini, kami akan menilai:

- Kualitas dan cakupan unit test.
- Implementasi caching (optional).
- Kualitas refactoring dan keterbacaan kode.

## Note
- Anda bisa menggunakan gem rspec untuk unit test
- Anda bisa menggunakan cache built-in rails atau third party sesuai pilihan Anda

## -----------------------UPDATED FROM RENDY------------------------------------------

- Saya sudah menambahkan tes: models, controllers(request), dan unit_tests (untuk case ini request tapi full mocking DB dan Memorystore)
- Saya sudah menambahkan cache mechanism di jobs_controller.rb saat index dengan param user_id
- step awal setelah clone: run bundle install (pastikan ruby dan rails version di lokal sesuai dengan Gemfile)
- untuk menjalankan tes models: bundle exec rspec spec/models
- untuk menjalankan tes controllers: bundle exec rspec spec/controllers
- untuk menjalankan tes units: bundle exec rspec spec/unit_tests
