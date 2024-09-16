#' Finlay-Wilkinson Regression Model
#'
#' This function calculates the slope of yield against the environment index for each genotype.
#' @param data A data frame containing the yield data.
#' @param env_cols A character vector of column names that describe the environment (e.g., Fertilizer, Irrigation).
#' @param genotype_col The name of the column containing the genotype or cultivar names.
#' @param yield_col The name of the column containing the yield values.
#' @return A data frame with the slopes for each genotype.
#' @export
#'
fwrmodel= function(data, env_cols, genotype_col, yield_cols) {
  library(dplyr)
  library(tidyr)
  library(broom)

  # Ensure the genotype column is treated as a factor
  data[[genotype_col]]= as.factor(data[[genotype_col]])

  # Initialize a list to store the results
  env_index_list= list()
  regression_list= list()

  # Loop over each yield column to calculate Env_index and perform regression
  for (yield_col in yield_cols) {
    # Calculate the average yield for each combination of environment and genotype
    df1= data %>%
      group_by(across(all_of(env_cols)), .data[[genotype_col]]) %>%
      summarise(Average_Yield= mean(.data[[yield_col]], na.rm= TRUE), .groups= 'drop') %>%
      mutate(Env= paste(!!!syms(env_cols), sep= "_")) %>%
      select(Env, all_of(genotype_col), Average_Yield) %>%
      pivot_wider(names_from= all_of(genotype_col), values_from= Average_Yield)

    # Calculate the mean yield across genotypes
    df1$Mean= rowMeans(select(df1, -Env), na.rm= TRUE)

    # Add the mean row and calculate the environment index
    df1= rbind(df1, c("Mean", colMeans(select(df1, -Env), na.rm= TRUE)))
    df1$Mean= as.numeric(df1$Mean)
    df1= df1 %>%
      mutate(!!paste0("Env_index_", yield_col) := Mean - Mean[nrow(.)]) %>%
      slice(-nrow(.))

    # Ensure the new Env_index column is numeric
    df1[[paste0("Env_index_", yield_col)]]= as.numeric(df1[[paste0("Env_index_", yield_col)]])

    # Merge the Env_index back to the original data
    pre_env_index= data %>%
      mutate(Env= paste(!!!syms(env_cols), sep= "_")) %>%
      left_join(df1 %>% select(Env, paste0("Env_index_", yield_col)), by= "Env", relationship= "many-to-many") %>%
      mutate(Environments= paste(!!!syms(env_cols), sep= "_")) %>%  # Create the "Environments" column
      select(all_of(genotype_col), all_of(env_cols), Environments, paste0("Env_index_", yield_col), all_of(yield_col))

    # Store the reshaped data with Env_index for this yield column
    env_index_list[[yield_col]]= pre_env_index

    # Perform linear regression for each genotype for this yield column
    regression= pre_env_index %>%
      group_by(.data[[genotype_col]]) %>%
      do(tidy(lm(.data[[yield_col]] ~ .data[[paste0("Env_index_", yield_col)]], data= .))) %>%
      mutate(term= gsub(paste0(".data\\[\\[\"Env_index_", yield_col, "\"\\]\\]"), paste0("Env_index_", yield_col), term))

    # Store the regression results for this yield column
    regression_list[[yield_col]]= regression
  }

  # Combine all Env_index columns into one dataset
  env_index= Reduce(function(x, y) left_join(x, y, by= c(env_cols, genotype_col, "Environments"), relationship= "many-to-many"), env_index_list)

  # Return a list with combined Env_index data and regression results
  return(list(regression= regression_list, env_index= env_index))
}
