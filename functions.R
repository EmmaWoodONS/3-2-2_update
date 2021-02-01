get_info_cells <- function(dat) {
  
  possible_geographies <- c("England", "Wales", "Scotland", "Northern Ireland", "UK", "United Kingdom")
  
  dat %>%
    filter(row %in% 1:(first_header_row_birthweight_by_mum_age - 1)) %>% 
    distinct(character) %>% 
    filter(!is.na(character)) %>% 
    mutate(character = trimws(character,  which = "both")) %>% 
    mutate(Year = ifelse(substr(character, nchar(character) - 3, nchar(character) - 2) == "20", 
                         substr(character, nchar(character) - 3, nchar(character)), 
                         NA)) %>% 
    mutate(Country = ifelse(grepl(possible_geographies, character, fixed = TRUE), character, NA))
  
}

get_year <- function(dat) {
  
  Years <- filter(dat, !is.na(Year)) %>% 
    select(Year)
  Years_list <- as.list(unique(Years))
  
  
  if (length(Years_list) > 1) {
    print("Error: code has identified more than one year, where only one was expected. Please check that Year is correct in the output")
  }
  
  Years_list[[1]]

  }

get_country <- function(dat) {
  
  Countries <- filter(dat, !is.na(Country)) %>% 
    select(Country)
  Countries_list <- as.list(unique(Countries))
  
  if (length(Countries_list) > 1) {
    print("Error: code has identified more than one geography. Please check that Country is correct in the output")
  } 
  
  Country <- str_c(Countries_list, collapse = " ")
  
}

#--------

remove_superscripts_blanks_and_info_cells <- function(dat) {
  
  dat <- remove_superscripts(dat)
  remove_blanks_and_info_cells(dat)
  
}

remove_superscripts <- function(dat) {

  superscript_regex_codes <- "[\u{2070}\u{00B9}\u{00B2}\u{00B3}\u{2074}-\u{2079}]"
  
  all_letters <-c(LETTERS, letters)
  
  dat %>%
    mutate(character = ifelse(get_first_character(character) %in% all_letters & get_second_character(character) %in% all_letters,
                              gsub(superscript_regex_codes, '', character),
                              character)) %>%
    # sometimes superscripts read in as normal numbers but we still want to remove them as the superscript may only occur in some years
    #   and may affect column names.
    # only remove the last number where the first TWO characters are letters because this identifies the string as a string not a number 
    # (If we only required the FIRST character to be a letter, Area code numbers would be affected)
    # only remove the last number when the character before the last character is not a space (as superscripts should not have a space before them)
    mutate(character = ifelse(get_first_character(character) %in% all_letters & get_second_character(character) %in% all_letters &
                                get_penultimate_character(character) != " ",  
                              gsub("[1-9]$", '', character), 
                              character)) 
}

remove_blanks_and_info_cells <- function(dat) {
  
  dat %>% 
    mutate(is_blank = ifelse(character == "" & data_type == "character", TRUE, is_blank)) %>%
    filter(is_blank == FALSE & row %not_in% 1:(first_header_row_birthweight_by_mum_age - 1)) 
  
}

get_first_character <- function(variable) {
  substr(variable, nchar(variable) - 1, nchar(variable) - 1)
}
get_second_character <- function(variable) {
  substr(variable, nchar(variable) - 1, nchar(variable) - 1)
}
get_penultimate_character <- function(variable) {
  substr(variable, nchar(variable) - 1, nchar(variable) - 1)
}

#--------


`%not_in%` <- Negate(`%in%`)
