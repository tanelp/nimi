### data extraction from html
#############################

extract_gender = function(x){
  is_male_name = grepl("mehel.", x)
  is_female_name = grepl("naisel.", x)

  if(is_male_name & is_female_name) "both"
  else if(!is_male_name & !is_female_name) NA
  else if(is_male_name) "male"
  else if(is_female_name) "female"
}

extract_name_count = function(text_input, gender){
  if(gender == "male"){
    pattern = paste0("([0-9]*) mehel")
  }
  else if(gender == "female"){
    pattern = paste0("([0-9]*) naisel")
  }

  res = stringr::str_match(text_input, pattern)
  as.numeric(res[1, ncol(res)])
}

extract_name_rank = function(text_input, gender){
  if(gender == "male"){
    pattern = "([0-9]*)\\. mehenimi"
  }
  else if(gender=="female"){
    pattern = "([0-9]*)\\. naisenimi"
  }

  res = stringr::str_match(text_input, pattern)
  as.numeric(res[1, ncol(res)])
}

extract_rank_sentence = function(text){
  has_rank = grepl("populaarsuselt", text)
  if(sum(has_rank) == 1) text[which(has_rank)]
  else NA
}

extract_month_script = function(scripts){
  has_month_data = grepl("polar", scripts)
  if(sum(has_month_data) == 1) scripts[which(has_month_data)]
  else NA
}

extract_month_data = function(scripts){
  x = extract_month_script(scripts)
  if(is.na(x)) return(NA)

  x = html_text(x)
  pattern = 'data\":\\[([0-9,]*)\\]'
  res = stringr::str_match(x, pattern)
  x = res[1, 2]
  x = strsplit(x, ",")[[1]]
  x = as.numeric(x)
  names(x) = c("Jan", "Feb", "Mar", "Apr", "May", "June", "July",
               "Aug", "Sept", "Oct", "Nov", "Dec")
  x
}

extract_county_script = function(scripts){
  has_county_data = grepl("Viljandi", scripts)
  if(sum(has_county_data) == 1) scripts[which(has_county_data)]
  else NA
}

extract_county_data = function(scripts){
  x = extract_county_script(scripts)
  if(is.na(x)) return(NA)

  x = html_text(x)
  pattern = 'data\":\\[([0-9,\\.]*)\\]'
  x = stringr::str_match(x, pattern)
  x = x[1, 2]
  x = strsplit(x, ",")[[1]]
  x = as.numeric(x)
  names(x) = c("Viljandi", "Põlva", "Jõgeva", "Tartu",
               "Pärnu", "Rapla", "Võru", "Lääne-Viru",
               "Lääne", "Hiiu", "Harju", "Järva", "Saare",
               "Valga", "Ida-Viru")
  x
}

extract_data = function(content, name){
  text = content %>%
    html_nodes("p") %>%
    html_text()
  text_rank = extract_rank_sentence(text)

  scripts = content %>%
    html_nodes("script")

  d = list()
  d[["text"]] = text
  d[["gender"]] = extract_gender(text_rank)
  d[["rank_male"]] = extract_name_rank(text_rank, gender="male")
  d[["rank_female"]] = extract_name_rank(text_rank, gender="female")
  d[["count_male"]] = extract_name_count(text_rank, "male")
  d[["count_female"]] = extract_name_count(text_rank, "female")
  d[["count_month"]] = extract_month_data(scripts)
  d[["count_county"]] = extract_county_data(scripts)
  d
}

### data getters
################

retrieve_data = function(name){
  base_url = "https://www.stat.ee/public/apps/nimed/"
  url = paste0(base_url, name)
  read_html(url)
}

get_data = function(name){
  d = retrieve_data(name)
  extract_data(d, name)
}

check_for_data = function(name){
  name = tolower(name)
  if(!exists(name, envir=pkg_env)){
    assign(name, get_data(name), envir=pkg_env)
  }
}

#' Determine the gender of a first name
#'
#' @param name first name.
#' @return The gender of the name - either \code{male}, \code{female} or \code{both}.
#' @examples
#' get_gender("Astrid")
#' @export

get_gender = function(name){
  name = tolower(name)
  check_for_data(name)
  get(name, envir=pkg_env)[["gender"]]
}

#' Determine the rank of a first name in Estonia
#'
#' @param name first name.
#' @return A numeric vector showing the popularity rank among female and male first names.
#' @examples
#' get_rank("Astrid")
#' @export

get_rank = function(name){
  name = tolower(name)
  check_for_data(name)
  x = c(get(name, envir=pkg_env)[["rank_male"]],
        get(name, envir=pkg_env)[["rank_female"]])
  names(x) = c("male", "female")
  x
}

#' Determine the frequency count of a first name in Estonia
#'
#' @param name first name.
#' @return A numeric vector showing the number of people having such a name.
#' @examples
#' get_count("Astrid")
#' @export

get_count = function(name){
  name = tolower(name)
  check_for_data(name)
  x = c(get(name, envir=pkg_env)[["count_male"]],
        get(name, envir=pkg_env)[["count_female"]])
  names(x) = c("male", "female")
  x
}

#' Determine the frequency count of a first name in Estonia by birth month
#'
#' @param name first name.
#' @return A numeric vector showing the number of people having such a name by birth month.
#' @examples
#' get_count_by_month("Astrid")
#' @export

get_count_by_month = function(name){
  name = tolower(name)
  check_for_data(name)
  x = get(name, envir=pkg_env)[["count_month"]]
  x
}

#' Determine the frequency count of a first name in Estonia by county
#'
#' @param name first name.
#' @return A numeric vector showing the number of people having such a name out of 10,000 people by county.
#' @examples
#' get_count_by_county("Astrid")
#' @export

get_normalized_count_by_county = function(name){
  name = tolower(name)
  check_for_data(name)
  x = get(name, envir=pkg_env)[["count_county"]]
  x
}

#' Get a summary description of a first name
#'
#' @param name first name.
#' @return A character vector summarising statistics about the first name.
#' @examples
#' describe("Astrid")
#' @export

describe = function(name){
  name = tolower(name)
  check_for_data(name)
  get(name, envir=pkg_env)[["text"]]
}
