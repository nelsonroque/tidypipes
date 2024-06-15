#' Send a message to Microsoft Teams using a webhook
#'
#' This function sends a message to a specified Microsoft Teams channel using the provided webhook URL.
#'
#' @param webhook_url The URL of the Microsoft Teams webhook.
#' @param title The title of the message.
#' @param text The content of the message.
#'
#' @return A message indicating whether the message was sent successfully or not.
#' @examples
#' webhook_url <- "https://example.webhook.office.com/webhookb2/..."
#' send_teams_webhook_message(webhook_url, "Test Title", "This is a test message.")
#' @export
send_teams_webhook_message <- function(webhook_url, title, text) {

  # Define the message payload
  message <- list(
    text = text,
    title = title
  )

  # Send a POST request to the Teams webhook URL with the payload
  response <- httr::POST(
    url = webhook_url,
    body = message,
    encode = "json"
  )

  # Check the response status code to verify if the message was sent successfully
  if (httr::status_code(response) == 200) {
    return("Message sent successfully")
  } else {
    return(paste("Failed to send message. Status code:", httr::status_code(response)))
  }
}
