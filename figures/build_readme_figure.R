library(ggplot2)

x = get_count_by_month("Jaanika")
df = data.frame(month = factor(names(x), levels=names(x)),
                count = as.numeric(x))

ggplot(df, aes(x=month, y=count, label=count)) +
  geom_bar(stat="identity", fill="#53cfff") +
  geom_text(col="white", vjust=1.25, size=3.5) +
  theme_minimal() +
  labs(title = expression(paste("People named ", bold("Jaanika"), " per birth month")),
       caption = "data source: Statistics Estonia")

ggsave("figures/jaanika.png")
