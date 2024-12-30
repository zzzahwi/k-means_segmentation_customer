# **Segmentasi Pelanggan Menggunakan K-Means Clustering**

Analisis ini bertujuan untuk mengelompokkan pelanggan berdasarkan pola pembelian mereka menggunakan metode K-Means Clustering. Segmentasi ini membantu perusahaan dalam memahami perilaku pelanggan dan merancang strategi pemasaran yang lebih efektif, seperti promosi yang ditargetkan atau personalisasi layanan.
________________________________________
## **1. Instalasi dan Muat Library yang Diperlukan**
Langkah pertama adalah memastikan bahwa semua library yang diperlukan telah terinstal dan dimuat.

```r
# Instalasi paket (jika belum terinstal)
install.packages("ggplot2")
install.packages("factoextra")
install.packages("dplyr")
install.packages("tidyr")
```
```r
# Muat library
library(ggplot2)
library(factoextra)
library(dplyr)
library(tidyr)
```
**Kegunaan Library:**
-	ggplot2: Untuk membuat visualisasi data yang menarik.
-	factoextra: Mempermudah visualisasi hasil analisis clustering.
-	dplyr: Untuk manipulasi data dengan sintaks sederhana.
-	tidyr: Mempermudah pengolahan format data (lebar ke panjang atau sebaliknya).
________________________________________
## **2. Membaca Dataset**
Dataset pelanggan dimuat dari clipboard (atau file lain, jika diperlukan).

```r
# Baca dataset dari clipboard
data <- read.delim("clipboard")
View(data)
```

*Catatan: Pastikan data yang disalin memiliki format yang sesuai, dengan kolom dan baris yang terstruktur rapi.*
________________________________________
## **3. Pemilihan Kolom Numerik untuk Clustering**
K-Means hanya dapat digunakan pada data numerik, sehingga kita perlu memilih kolom yang relevan.

```r
# Pilih hanya kolom numerik untuk clustering
data_numeric <- data %>% select_if(is.numeric)
```
Data numerik meliputi fitur seperti jumlah pembelian di toko, pembelian online, atau pengeluaran total.
________________________________________
## **4. Normalisasi Data**
Langkah normalisasi dilakukan untuk memastikan semua variabel memiliki skala yang sama.
```r
# Normalisasi data
data_scaled <- scale(data_numeric)
```
Variabel dengan skala besar (misalnya, total pembelian) bisa mendominasi variabel lain dalam clustering jika tidak dinormalisasi.
________________________________________
## **5. Melakukan Clustering dengan K-Means**
Setelah jumlah cluster ditentukan, lakukan K-Means clustering.
```r
# Lakukan clustering dengan jumlah cluster yang ditentukan (misalnya 3)
set.seed(123) #Untuk hasil yang konsisten
kmeans_result <- kmeans(data_scaled, centers = 3, nstart = 25)
```
```r
# Tambahkan hasil cluster ke data asli
data$Cluster <- as.factor(kmeans_result$cluster)
```
*Catatan: Kolom baru bernama Cluster ditambahkan ke dataset untuk menunjukkan cluster masing-masing pelanggan.*
________________________________________
## **6. Visualisasi Hasil Clustering**
Hasil clustering divisualisasikan dalam ruang 2 dimensi menggunakan PCA (Principal Component Analysis).
```r
# Visualisasi hasil clustering
fviz_cluster(kmeans_result, data = data_scaled, geom = "point", ellipse.type = "convex") +
  labs(title = "Visualisasi Cluster dengan PCA")
```
Hasil Visualisasi: Lampirkan grafik cluster di sini.
![alt text](https://github.com/zzzahwi/k-means_segmentation_customer/blob/main/visualisasi/clustering_k-means_newest.png?raw=true)
Setiap titik mewakili pelanggan, sementara warna menunjukkan cluster yang ditentukan.
________________________________________
## **7. Ringkasan Statistik untuk Setiap Cluster**
Ringkasan statistik memberikan informasi tentang karakteristik rata-rata dari setiap cluster.
```r
# Ringkasan statistik untuk setiap cluster
summary_per_cluster <- data %>%
  group_by(Cluster) %>%
  summarise(across(where(is.numeric), mean, na.rm = TRUE))
print(summary_per_cluster)
```
Hasil Ringkasan Statistik: Lampirkan tabel ringkasan di sini.
![alt text](https://github.com/zzzahwi/k-means_segmentation_customer/blob/main/visualisasi/Screenshot%202024-12-30%20235237.png?raw=true)
________________________________________
## **8. Distribusi Pembelian Toko dan Web per Cluster**
Untuk memahami perbedaan pola pembelian, analisis distribusi pembelian di toko dan web dilakukan.
```r
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
```
Hasil Visualisasi: Lampirkan pie chart.
![alt text](https://github.com/zzzahwi/k-means_segmentation_customer/blob/main/visualisasi/distribusi_store-web_per%20cluster.png?raw=true)
Setiap cluster memiliki proporsi pembelian toko dan web yang berbeda, yang mencerminkan preferensi pelanggan.
________________________________________
## **9. Transformasi Data untuk Visualisasi**
Data kemudian diproses dalam format panjang (long format) agar lebih mudah divisualisasikan.
```r
percentages_long <- percentages %>%
  pivot_longer(
    cols = starts_with("Percent"),
    names_to = "Category",
    values_to = "Percentage"
  )
```
Transformasi data ini mempermudah visualisasi menggunakan grafik pie chart yang menunjukkan distribusi pembelian per cluster.
________________________________________
## **10. Visualisasi Distribusi Pembelian Toko dan Web**

Selanjutnya, kita membuat grafik pie chart untuk menampilkan distribusi pembelian di toko dan online di setiap cluster.
```r
ggplot(percentages_long, aes(x = "", y = Percentage, fill = as.factor(Cluster_No_ID))) +
  geom_bar(stat = "identity", width = 1) +
  coord_polar("y", start = 0) +
  facet_wrap(~Category, ncol = 2) + # Dua chart berdampingan
  geom_text(
    aes(label = paste0(round(Percentage, 1), "%")),
    position = position_stack(vjust = 0.5), # Letakkan label di tengah segmen
    size = 4, color = "white"
  ) +
  labs(
    title = "Distribusi Persentase NumStore dan NumWeb Purchases per Cluster",
    fill = "Cluster",
    x = NULL,
    y = NULL
  ) +
  theme_minimal() +
  theme(
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    panel.grid = element_blank(),
    strip.text = element_text(size = 12, face = "bold")
  )
 ```
Grafik ini memberikan gambaran visual yang jelas tentang proporsi pembelian di toko dan web per cluster, yang dapat membantu dalam analisis perilaku pelanggan.
________________________________________
## **11. Visualisasi Distribusi Pembelian Toko dan Web**

Langkah ini memeriksa distribusi produk yang dibeli oleh pelanggan dalam setiap cluster, untuk melihat preferensi produk yang berbeda di setiap kelompok.
 ```r
products <- c("MntWines", "MntFruits", "MntMeatProducts", "MntFishProducts", 
              "MntSweetProducts", "MntGoldProds", "Cluster_No_ID")
data_products <- data[, products]
 ```

![alt text](https://github.com/zzzahwi/k-means_segmentation_customer/blob/main/visualisasi/distribusi_store-web_per%20cluster_3.png?raw=true)
Data produk yang dibeli disaring, dan hasilnya digunakan untuk menganalisis preferensi produk setiap cluster.
________________________________________
## **12. Visualisasi Distribusi Produk**
Terakhir, kita visualisasikan distribusi produk yang dibeli per cluster dengan menggunakan grafik pie chart untuk menggambarkan preferensi produk.
 ```r
ggplot(cluster_long, aes(x = "", y = Percentage, fill = Product)) +
  geom_bar(stat = "identity", width = 1) +
  coord_polar("y", start = 0) +
  facet_wrap(~Cluster_No_ID) +
  geom_text(
    aes(label = paste0(round(Percentage, 1), "%")),
    position = position_stack(vjust = 0.5),
    size = 3
  ) +
  labs(
    title = "Distribusi Produk per Cluster",
    fill = "Produk",
    x = NULL,
    y = NULL
  ) +
  theme_minimal() +
  theme(
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    panel.grid = element_blank(),
    strip.text = element_text(size = 12, face = "bold")
  )
 ```
![alt text](https://github.com/zzzahwi/k-means_segmentation_customer/blob/main/visualisasi/distribusi_produk_per%20cluster.png?raw=true)
Grafik ini menunjukkan persentase produk yang dibeli dalam setiap cluster, memberikan wawasan lebih dalam mengenai preferensi pelanggan.

## **Kesimpulan**
Dari analisis ini, diperoleh wawasan berikut:
1.	Dataset pelanggan berhasil dikelompokkan menjadi beberapa cluster dengan karakteristik yang berbeda.
2.	Cluster menunjukkan pola pembelian yang unik, seperti preferensi untuk belanja di toko dibandingkan online, atau tingkat pengeluaran yang berbeda.


