# Instal dan muat library yang diperlukan
library(ggplot2)
library(factoextra)
library(dplyr)

# 1. Baca dataset
data <- read.delim("clipboard")
View(data)

# 2. Hapus kolom ID sebelum analisis clustering
data_no_id <- data[, !(names(data) %in% c("ID"))]

# 3. Normalisasi data (menggunakan data tanpa ID)
data_scaled <- scale(data)

# 4. Clustering dengan semua kolom (termasuk data lainnya, kecuali ID)
kmeans_all <- kmeans(data_scaled, centers = 3, nstart = 25)
data$Cluster_All <- as.factor(kmeans_all$cluster)

# 5. Pilih hanya kolom numerik untuk clustering (jika sebelumnya belum)
data_numeric_no_id <- data_no_id[sapply(data_no_id, is.numeric)]

# 6. Normalisasi data
data_scaled_no_id <- scale(data_numeric_no_id)

# 7. Lakukan clustering
kmeans_no_id <- kmeans(data_scaled_no_id, centers = 3, nstart = 25)
data$Cluster_No_ID <- as.factor(kmeans_no_id$cluster)

# 8. Visualisasi hasil clustering
pca_no_id <- prcomp(data_scaled_no_id, scale = TRUE)
fviz_cluster(kmeans_no_id, data = data_scaled_no_id, geom = "point", ellipse.type = "convex",
             ggtheme = theme_minimal(), main = "Clustering dengan Semua Kolom (Kecuali ID)")

# 9. Ringkasan statistik untuk setiap cluster
summary_per_cluster <- data %>%
  group_by(Cluster_No_ID) %>%
  summarise(across(where(is.numeric), mean, na.rm = TRUE))

print(summary_per_cluster)

# 10. Jumlah anggota dalam setiap cluster
table(data$Cluster_No_ID)


#------Visualisasi-----

library(tidyr)
library(ggplot2)

# Pilih kolom terkait produk dan Cluster
products <- c("MntWines", "MntFruits", "MntMeatProducts", "MntFishProducts", 
              "MntSweetProducts", "Cluster_No_ID")
data_products <- data[, products]

# Hitung total produk per cluster
cluster_totals <- data_products %>%
  group_by(Cluster_No_ID) %>%
  summarise(across(everything(), sum, na.rm = TRUE))

# Transformasi data ke format long untuk visualisasi
cluster_long <- cluster_totals %>%
  pivot_longer(
    cols = -Cluster_No_ID,
    names_to = "Product",
    values_to = "Total"
  ) %>%
  group_by(Product) %>%
  mutate(Percentage = Total / sum(Total) * 100) %>%
  ungroup()

# Buat pie chart untuk setiap produk
ggplot(cluster_long, aes(x = "", y = Percentage, fill = as.factor(Cluster_No_ID))) +
  geom_bar(stat = "identity", width = 1) +
  coord_polar("y", start = 0) +
  facet_wrap(~Product) +
  geom_text(
    aes(label = paste0(round(Percentage, 1), "%")),
    position = position_stack(vjust = 0.5),
    size = 3
  ) +
  labs(
    title = "Distribusi Persentase Produk di Tiap Cluster",
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

#------Visualisasi-----

library(tidyr)
library(ggplot2)
library(dplyr)

# Hitung jumlah total NumStore dan NumWeb per cluster
percentages <- data %>%
  group_by(Cluster_No_ID) %>%
  summarise(
    Total_NumStorePurchases = sum(NumStorePurchases, na.rm = TRUE),
    Total_NumWebPurchases = sum(NumWebPurchases, na.rm = TRUE)
  ) %>%
  mutate(
    Percent_NumStorePurchases = Total_NumStorePurchases / (Total_NumStorePurchases + Total_NumWebPurchases) * 100,
    Percent_NumWebPurchases = Total_NumWebPurchases / (Total_NumStorePurchases + Total_NumWebPurchases) * 100
  ) %>%
  select(Cluster_No_ID, Percent_NumStorePurchases, Percent_NumWebPurchases)

# Transformasi ke long format untuk visualisasi
percentages_long <- percentages %>%
  pivot_longer(
    cols = starts_with("Percent"),
    names_to = "Category",
    values_to = "Percentage"
  ) %>%
  mutate(Category = recode(Category, 
                           "Percent_NumStorePurchases" = "NumStorePurchases",
                           "Percent_NumWebPurchases" = "NumWebPurchases"),
         Label = paste0(round(Percentage, 1), "%")  # Buat kolom Label
  )

#Hitung posisi label untuk menampilkan angka
ggplot(percentages_long, aes(x = "", y = Percentage, fill = Category)) +
  geom_bar(stat = "identity", width = 1) +
  coord_polar("y", start = 0) +
  geom_text(
    aes(label = Label),
    position = position_stack(vjust = 0.5),  # Letakkan label di tengah segmen
    size = 4, color = "white"
  ) +
  facet_wrap(~Cluster_No_ID) +
  labs(
    title = "Distribusi Persentase NumStore dan NumWeb per Cluster",
    fill = "Kategori",
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

# Pilih kolom terkait produk dan Cluster
products <- c("MntWines", "MntFruits", "MntMeatProducts", "MntFishProducts", 
              "MntSweetProducts", "MntGoldProds", "Cluster_No_ID")
data_products <- data[, products]

# Hitung total produk per cluster
cluster_totals <- data_products %>%
  group_by(Cluster_No_ID) %>%
  summarise(across(everything(), sum, na.rm = TRUE))

# Transformasi data ke format long untuk visualisasi
cluster_long <- cluster_totals %>%
  pivot_longer(
    cols = -Cluster_No_ID,
    names_to = "Product",
    values_to = "Total"
  ) %>%
  group_by(Cluster_No_ID) %>%
  mutate(Percentage = Total / sum(Total) * 100) %>%
  ungroup()

# Buat pie chart untuk setiap cluster
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