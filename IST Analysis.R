---
title: "IST Analysis"
author: "Irene Kimura Park"
date: ''
output:
  pdf_document: default
  html_document: default
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
library(tidyverse)
library(expss)
library(table1)
library(mediation)
```

### IST Dataset
```{r}
#Reading in Dataset
ist <- read.csv("C:/Irene Park's Documents/Academics/MS Applied Biostatistics/BS 851 - Applied Statistics in Clinical Trials I/Project/IST.csv") %>%
#Selecting Variables for Analysis
  dplyr::select(sex = SEX, 
                age = AGE, 
                aspirin = RXASP, 
                heparin = RXHEP, 
                hemorrhagic_stroke = DRSH, 
                pulmonary_embolism = DPE) %>% 
#Creating Treatment Variable & Recoding Sex 
  mutate(trt = case_when((aspirin=="Y" & heparin=="N") ~ "Y", 
                         (aspirin=="N" & heparin=="N") ~ "N"),
         sex = recode_factor(sex, "M"="Male", "F"="Female")) %>%
#Selecting Subjects of Interest
  filter(trt %in% c("Y", "N") & 
         hemorrhagic_stroke %in% c("Y", "N") & 
         pulmonary_embolism %in% c("Y", "N")
         ) %>% 
#Converting Factors to Binomial Variables
  mutate_at(c("hemorrhagic_stroke", "pulmonary_embolism", "trt"), 
            list(~dplyr::recode(., "N"=0, .default=1))) %>%
#Remove Unwanted Variables
  dplyr::select(-c(aspirin, heparin)) %>%
#Labeling Variables
  apply_labels(sex = "Sex", 
               age = "Age", 
               trt="Treatment",
               hemorrhagic_stroke = "Recurrent Hemorrhagic Stroke", 
               pulmonary_embolism = "Pulmonary Embolism")

#Descriptive Statistics
table_html <- table1(~sex + age + factor(hemorrhagic_stroke) +factor(pulmonary_embolism) | factor(trt), data=ist, overall="Total", rowlabelhead="Treatment", caption="IST Dataset")
```



### Mediation Analysis
```{r}
#Logarithmic Mediator Model
mediator_model <- glm(pulmonary_embolism ~ trt + age + sex, data=ist, family="binomial")
summary(mediator_model)


#Logarithmic Outcome Model
outcome_model <- glm(hemorrhagic_stroke ~ trt + pulmonary_embolism + age + sex, data=ist, family="binomial")
summary(outcome_model)


#Calculating Mediated Effects
set.seed(1234)
mediated_effects <- mediate(mediator_model, outcome_model, treat="trt", mediator="pulmonary_embolism")
summary(mediated_effects)
```
