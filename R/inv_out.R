#' Title
#'
#' @param x
#' @param forest
#' @param path
#' @param overwrite
#'
#' @return
#' @export
#'
#' @examples
inv_out <- function (x, forest = getOption("RconTroll.forest"), path = getOption("RconTroll.path"),
                     overwrite = TRUE)
{
  # if (dim(x@full_final)[1] > 0)
  #   data <- x@full_final
  # else
  data <- as.data.frame(x@final_pattern)[c("x", "y",
                                           "dbh", "sp_lab")]
  data <- data[!(data$sp_lab == 0), ]
  data$species <- row.names(x@sp_par[data$sp_lab, ])
  data$dbh <- data$dbh * 1000
  data <- data[!(data$dbh == 0), ]
  if (!overwrite)
    if (forest %in% list.files(path))
      stop("The file already exist, use overwrite = T.")
  write.table(data, file = file.path(path, forest), row.names = FALSE,
              quote = FALSE, sep = "\t")
  return(data)
}
