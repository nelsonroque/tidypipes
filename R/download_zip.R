#' Download and Manage a ZIP File from a Remote Server
#'
#' This function downloads a ZIP file from a remote server using an HTTP POST request,
#' optionally extracts its contents, and removes the ZIP file after extraction.
#'
#' @param url A string specifying the remote server URL.
#' @param params A list of parameters to be included in the POST request.
#' @param save_filename A string specifying the name to save the downloaded ZIP file as.
#' @param save_path A string specifying the directory where the file should be saved.
#' @param overwrite_zip A logical value. If TRUE, overwrites the existing ZIP file. Default is FALSE.
#' @param unzip A logical value. If TRUE, extracts the ZIP file after download. Default is TRUE.
#' @param unzip_folder A string specifying the folder name inside the ZIP file to extract. If NULL, extracts everything.
#' @param remove_zip A logical value. If TRUE, deletes the ZIP file after extraction. Default is FALSE.
#' @return A list containing:
#'   - `zip_location`: The full path of the downloaded ZIP file.
#'   - `extracted_files`: A vector of extracted filenames (if unzipping was requested).
#' @export
#'
#' @examples
#' \dontrun{
#' download_zip(
#'   url = "https://example.com/data.zip",
#'   params = list(api_key = "12345"),
#'   save_filename = "data.zip",
#'   save_path = "downloads",
#'   unzip = TRUE,
#'   remove_zip = FALSE
#' )
#' }
download_zip <- function(url, params, save_filename, save_path,
                                overwrite_zip = FALSE, unzip = TRUE,
                                unzip_folder = NULL, remove_zip = FALSE) {
  # Ensure the save path exists
  if (!dir.exists(save_path)) {
    dir.create(save_path, recursive = TRUE)
  }

  # Define the full path for saving the file
  save_filepath <- file.path(save_path, save_filename)

  message("Downloading data from remote server: ", url)

  # Attempt the file download
  res <- tryCatch(
    {
      httr::POST(url, body = params, encode = "form", httr::write_disk(save_filepath, overwrite = overwrite_zip))
    },
    error = function(e) {
      message("Error downloading file: ", e$message)
      return(NULL)
    }
  )

  if (is.null(res)) return(list(zip_location = NULL, extracted_files = NULL))

  extracted_files <- NULL  # Default value for return

  # Unzip if requested
  if (unzip) {
    message("Extracting ZIP file: ", save_filepath)
    unzip_result <- tryCatch(
      {
        unzip(save_filepath, exdir = save_path)
        TRUE
      },
      error = function(e) {
        message("Error extracting ZIP file: ", e$message)
        return(FALSE)
      }
    )

    if (unzip_result) {
      extracted_files <- if (!is.null(unzip_folder)) {
        # List specific extracted folder contents
        list.files(file.path(save_path, unzip_folder), recursive = TRUE, full.names = TRUE)
      } else {
        # List all extracted files
        list.files(save_path, recursive = TRUE, full.names = TRUE)
      }
    } else {
      extracted_files <- "ERROR: Unable to extract ZIP file"
    }
  }

  # Remove the ZIP file if requested
  if (remove_zip) {
    message("Removing ZIP file: ", save_filepath)
    file.remove(save_filepath)
  }

  return(list(zip_location = save_filepath, extracted_files = extracted_files))
}
