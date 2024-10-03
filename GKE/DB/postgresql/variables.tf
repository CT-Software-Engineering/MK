variable "project_id" {
  description = "The GCP project ID"
  type        = string
  default     = "militaryknowledge"
}

variable "region" {
  description = "The GCP region"
  type        = string
  default     = "europe-west1"
}
variable "zone" {
  description = "The GCP zone"
  type        = string
  default     = "europe-west1-b"

}
variable "postgresql_password" {
  description = "The password for the PostgreSQL user"
  type        = string
  sensitive   = true
  default     = "pa55Word"
}
variable "postgresql_username" {
  description = "The password for the PostgreSQL user"
  type        = string
  sensitive   = true
  default     = "admin"
}
variable "postgresql_engine_size" {
  description = "Engine Size for PostgreSQL"
  type =   string
  default     = "db-f1-micro"
}
variable "kubernetes_token" {
  description = "Kubnernetes Token"
  type = string
  default = "ya29.c.c0ASRK0GbOoPqXFkl8N4YUFul03KyviEIZSqNnKjWpp_gnCXyxRjyxvMD-VFPQAKf3Fv4xnA4ow1j2H1QblrR3BGHLzJGBlyUMkg2hFy0hCJIIJZw-51YK-sm1ES-wgNNlkp7Rtsmz8XgqnJpLlZq610V2z_RxJxU86m2jbMJpoREy0-gTFyWreHp2_rsvcFdSr9gyvlsxaFz4SP14HpWpsvwZawSv5n_8l2u9dCd2-TeCrnS15yJtOTutg4kTy16Q7zUxFZLwWc4iGEE4Pq2kZI13hMzIemmIZnKIuUEfQ_lZ2ouKLPVwbvQUIhpHkrut-WFwZcEFWf1rKKXJVNjSF-VlvuhdUkc0V_iRhvQMKb_ErywrfHenRO8bw7SnT389D2-hImu-ZqfwxUwOB3w4sVdtowo18363XSJFIFia4tgh-M6utgzac15jFcnu81diJs9hIUdwdU_bsBtvW8rI3vUkZzSf0mV7h-hrfWllzwweV8auq8-8tRf0i78F08tQQpgqIm0SkSZ5fYkI3aXu12OdW1YgJdFZlSlyqXYoYIc_4eniB4XWqs0vI989ew0iQtdZBWbj18kBX-ec1XFi0exsp7_ngl3uxg2rnF6F5_qo9aWccSkjfn2kXFJqM-jf0iJjgmr2s1FsIR5i9F-xy72JxRBoc50tWaUX40wOk0wxQr15ao0m9_XQ8RSBZicqwXmylI9qk_RMov-eZ4cSXJxB-nJ9qB3JSd3XbzBOsBgbly5Y11YSUSSedbBtyeOvnVQnnVVbjcqraxlmXc4efvtO__3y5afB1Xbz_oYBZM5g9YoR2uwB2UVvetk1Xv1onzxxvb9UW6vFXWueyRSb7r2yFZtbQSekSmSZ4uuOxaR38-9cX8Z9IM6l-XuxgZyIr7XOoVdUX7iIyQIJlfejkrQQi2OopezJb0p7r4Xw4fl_ISwunvcFJZrmIW6YSZSWfFRnIf9ft3aJlkb3OveJjq2S6VMRnFaFtOa8kIRqlV1yOgraSWdsy67"
  
}