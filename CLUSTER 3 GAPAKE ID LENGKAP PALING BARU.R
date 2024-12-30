<h1> Segmentasi Pelanggan Menggunakan K-Means Clustering </h1>
Analisis ini bertujuan untuk mengelompokkan pelanggan berdasarkan pola pembelian mereka menggunakan metode K-Means Clustering. Segmentasi ini membantu perusahaan dalam memahami perilaku pelanggan dan merancang strategi pemasaran yang lebih efektif, seperti promosi yang ditargetkan atau personalisasi layanan.

1. Instalasi dan Muat Library yang Diperlukan
Langkah pertama adalah memastikan bahwa semua library yang diperlukan telah terinstal dan dimuat.

r
Copy code
# Instalasi paket (jika belum terinstal)
install.packages("ggplot2")
install.packages("factoextra")
install.packages("dplyr")
install.packages("tidyr")

# Muat library
library(ggplot2)
library(factoextra)
library(dplyr)
library(tidyr)
Kegunaan Library:

ggplot2: Untuk membuat visualisasi data yang menarik.
factoextra: Mempermudah visualisasi hasil analisis clustering.
dplyr: Untuk manipulasi data dengan sintaks sederhana.
tidyr: Mempermudah pengolahan format data (lebar ke panjang atau sebaliknya).
2. Membaca Dataset
Dataset pelanggan dimuat dari clipboard (atau file lain, jika diperlukan).

r
Copy code
# Baca dataset dari clipboard
data <- read.delim("clipboard")
View(data)
Catatan: Pastikan data yang disalin memiliki format yang sesuai, dengan kolom dan baris yang terstruktur rapi.

3. Pemilihan Kolom Numerik untuk Clustering
K-Means hanya dapat digunakan pada data numerik, sehingga kita perlu memilih kolom yang relevan.

r
Copy code
# Pilih hanya kolom numerik untuk clustering
data_numeric <- data %>% select_if(is.numeric)
Data numerik meliputi fitur seperti jumlah pembelian di toko, pembelian online, atau pengeluaran total.

4. Normalisasi Data
Langkah normalisasi dilakukan untuk memastikan semua variabel memiliki skala yang sama.

r
Copy code
# Normalisasi data
data_scaled <- scale(data_numeric)
Alasan Normalisasi: Variabel dengan skala besar (misalnya, total pembelian) bisa mendominasi variabel lain dalam clustering jika tidak dinormalisasi.

5. Menentukan Jumlah Cluster Optimal
Metode Elbow digunakan untuk menentukan jumlah cluster yang ideal berdasarkan Within-Cluster Sum of Squares (WSS).

r
Copy code
# Tentukan jumlah cluster optimal
fviz_nbclust(data_scaled, kmeans, method = "wss") +
  labs(title = "Metode Elbow untuk Menentukan Jumlah Cluster")
Hasil Visualisasi: Lampirkan grafik Elbow di sini.

Interpretasi: Jumlah cluster optimal berada di titik di mana penurunan WSS mulai melambat (titik siku).

6. Melakukan Clustering dengan K-Means
Setelah jumlah cluster ditentukan, lakukan K-Means clustering.

r
Copy code
# Lakukan clustering dengan jumlah cluster yang ditentukan (misalnya 3)
set.seed(123) # Untuk hasil yang konsisten
kmeans_result <- kmeans(data_scaled, centers = 3, nstart = 25)

# Tambahkan hasil cluster ke data asli
data$Cluster <- as.factor(kmeans_result$cluster)
Catatan: Kolom baru bernama Cluster ditambahkan ke dataset untuk menunjukkan cluster masing-masing pelanggan.

7. Visualisasi Hasil Clustering
Hasil clustering divisualisasikan dalam ruang 2 dimensi menggunakan PCA (Principal Component Analysis).

r
Copy code
# Visualisasi hasil clustering
fviz_cluster(kmeans_result, data = data_scaled, geom = "point", ellipse.type = "convex") +
  labs(title = "Visualisasi Cluster dengan PCA")
Hasil Visualisasi: Lampirkan grafik cluster di sini.

Interpretasi: Setiap titik mewakili pelanggan, sementara warna menunjukkan cluster yang ditentukan.

8. Ringkasan Statistik untuk Setiap Cluster
Ringkasan statistik memberikan informasi tentang karakteristik rata-rata dari setiap cluster.

r
Copy code
# Ringkasan statistik untuk setiap cluster
summary_per_cluster <- data %>%
  group_by(Cluster) %>%
  summarise(across(where(is.numeric), mean, na.rm = TRUE))
print(summary_per_cluster)
Hasil Ringkasan Statistik: Lampirkan tabel ringkasan di sini.

9. Distribusi Pembelian Toko dan Web per Cluster
Untuk memahami perbedaan pola pembelian, analisis distribusi pembelian di toko dan web dilakukan.

r
Copy code
# Hitung total dan persentase pembelian di toko dan web per cluster
percentages <- data %>%
  group_by(Cluster) %>%
  summarise(
    Total_NumStorePurchases = sum(NumStorePurchases, na.rm = TRUE),
    Total_NumWebPurchases = sum(NumWebPurchases, na.rm = TRUE)
  ) %>%
  mutate(
    Percent_NumStorePurchases = Total_NumStorePurchases / (Total_NumStorePurchases + Total_NumWebPurchases),
    Percent_NumWebPurchases = Total_NumWebPurchases / (Total_NumStorePurchases + Total_NumWebPurchases)
  )
print(percentages)
Hasil Visualisasi: Lampirkan grafik batang atau pie chart.

Interpretasi: Setiap cluster memiliki proporsi pembelian toko dan web yang berbeda, yang mencerminkan preferensi pelanggan.

10. Kesimpulan
Dari analisis ini, diperoleh wawasan berikut:

Dataset pelanggan berhasil dikelompokkan menjadi beberapa cluster dengan karakteristik yang berbeda.
Cluster menunjukkan pola pembelian yang unik, seperti preferensi untuk belanja di toko dibandingkan online, atau tingkat pengeluaran yang berbeda.
Informasi ini dapat digunakan untuk:
Menyesuaikan strategi pemasaran (misalnya, promosi khusus untuk pelanggan yang lebih suka belanja online).
Memberikan layanan personalisasi untuk meningkatkan loyalitas pelanggan.
