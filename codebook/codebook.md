# Transition Spillovers? The Protest Behaviour of the 1989 Generation in Europe
## Codebook (final dataset: `data/master.dta`)
Philippe Joly (2019)

---

### Variable List

| Variable        | Description
| --------------- | ---------------------------------------------------------
| `essround`      | ESS round
| `idno`          | Respondent's identification number
| `country`       | Country, ISO three-letter country code 
| `countrywave`   | Country-wave
| `dweight`       | Design weight
| `demonstration` | Taken part in lawful public demonstration, last 12 months
| `petition`      | Signed petition, last 12 months
| `boycott`       | Boycotted certain products, last 12 months
| `gen1989`       | Generation 1989
| `female`        | Gender
| `agerel`        | Relative age among members of the 1989 generation
| `edu`           | Highest level of education
| `unemp`         | Unemployed
| `native`        | Born in country
| `union`         | Member of trade union or similar organisation
| `city`          | Size of town/city
| `class5`        | Final Oesch class position - 5 classes
| `newdem`        | New democracy
| `earlyprotest`  | Early exposure to protest
| `year`          | Year of the survey (mode within a country-wave)
| `lgdp_mean`     | GDP per capita: country-mean
| `lgdp_diff`     | GDP per capita: within-country difference

---
### Note on the subsample

The ranges and unique values of the numeric variables are based on the subsample of the 1989 generation. 

---

### `essround`
**Type**: numeric

**Description**: ESS round

**Range**: [1, 8]

**Unique values**: 8

---

### `idno`
**Type**: numeric

**Description**: Respondent's identification number

**Range**: [1,5.097e+11]

**Unique values**: 25,372

**Note**: A unique identification number can be obtained by combining the country, the ESS round, and this variable. The procedure to attribute respondents an identification number was not implemented systematically in all the ESS rounds which explains the difference between the unique values of `idno` and the number of observations in the analysis. 

---

### `country`

**Type**: character

**Description**: Country, ISO three-letter country code

**Unique values**: 25

---

### `countrywave`

**Type**: character

**Description**: Country-wave

**Unique values**: 167

**Note**: `union` is missing in ESP6; `class5` is missing in ESP3, ITA2, and LVA3; `dweight` is missing in LVA3. The effective number of country-waves is 163.

---

### `dweight`
**Type**: numeric

**Description**: Design weight

**Range**: [.00914533,5.195318]

**Unique values**: 9,116

---

### `demonstration`
**Type**: factor

**Description**: Taken part in lawful public demonstration, last 12 months

**Coding**:

1. Not done
2. Have done

---

### `petition`
**Type**: factor

**Description**: Signed petition, last 12 months

**Coding**:

1. Not done
2. Have done

---

### `boycott`
**Type**: factor

**Description**: Boycotted certain products, last 12 months

**Coding**:

1. Not done
2. Have done

---

### `gen1989`
**Type**: factor

**Description**: Generation 1989

**Coding**:

1. Not member
2. Member

---

### `female`
**Type**: factor

**Description**: Gender

**Coding**:

1. Man
2. Woman

---

### `agerel`
**Type**: numeric

**Description**: Relative age among members of the 1989 generation

**Range**: [0,8]

**Unique values**: 9

**Note**: range and unique values with

---

### `edu`
**Type**: factor

**Description**: Highest level of education

**Coding**:

1. Lower
2. Middle
3. Higher

**Note**: _Lower_ recoded from `eisced`[1,2] OR `edulvla`[1,2]; _Middle_ recoded from `eisced`[3,4] OR `edulvla`[3,4]; _Higher_ recoded from `eisced`[5,7] OR `edulvla`[5].

---

### `unemp`
**Type**: factor

**Description**: Unemployed

**Coding**:

1. No
2. Yes

---

### `union`
**Type**: factor

**Description**: Member of trade union or similar organisation

**Coding**:

1. No
2. Yes, currently or previously

---

### `native`
**Type**: factor

**Description**: Born in country

**Coding**:

1. Non native
2. Native

---

### `city`
**Type**: factor

**Description**: Size of town/city

**Coding**:

1. Farm or home in countryside
2. Country village
3. Town or small city
4. Suburbs or outskirts of big city
5. A big city


---

### `class5`
**Type**: factor

**Description**: Final Oesch class position - 5 classes

**Coding**:

1. Unskilled workers
2. Skilled workers
3. Small business owners
4. Lower-grade service class
5. Higher-grade service class

---

### `newdem`
**Type**: factor

**Description**: New democracy

**Coding**:

1. Old democracy
2. New democracy

---

### `earlyprotest`
**Type**: numeric

**Description**: Early exposure to protest

**Range**: [0.07142857,0.61153047]

**Unique values**: 25

---

### `year`
**Type**: numeric

**Description**: Year of the survey (mode within a country-wave)

**Range**: [2002,2017]

**Unique values**: 16

---

### `lgdp_mean`
**Type**: numeric

**Description**: GDP per capita: country-mean

**Range**: [9.6256166,11.045565]

**Unique values**: 25

---

### `lgdp_diff`
**Type**: numeric

**Description**: GDP per capita: within-country difference

**Range**: [-.28960738,.32525378]

**Unique values**: 167
