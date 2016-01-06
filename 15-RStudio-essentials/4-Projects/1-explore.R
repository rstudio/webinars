library(ggplot2)
library(dplyr)
library(broom)


heights <- read.csv("heights.csv")

# Height vs. income
ggplot(heights, aes(height, income)) +
  geom_point() +
  geom_smooth()

mod1 <- tidy(lm(income ~ height, data = heights))
mod1


# persists with education
mod2 <- tidy(lm(income ~ height + education, data = heights))
mod2


# Sex may have an effect
ggplot(heights, aes(sex, income)) +
  geom_boxplot()

mod3 <- tidy(lm(income ~ sex, data = heights))
mod3

# Nice interaction effect
mod4 <- tidy(lm(income ~ height + sex, data = heights))
mod4
mod5 <- tidy(lm(income ~ height * sex, data = heights))
mod5
ggplot(heights, aes(height, income)) +
  geom_point() +
  geom_smooth(aes(color = sex), method = lm)

