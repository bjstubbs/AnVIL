#' @rdname Service
#'
#' @name Service
#'
#' @title RESTful services useful for AnVIL developers
#'
#' @aliases .DollarNames.Service operations,Service-method
#'     schemas,Service-method show,Service-method Service-class
#'
#' @param x A `Service` instance, usually a singleton provided by the
#'     package and documented on this page, e.g., `leonardo` or
#'     `terra`.
#'
#' @param name A symbol representing a defined operation, e.g.,
#'     `leonardo$listClusters()`.
#'
#' @import methods
NULL

setOldClass("rapi_api")

setOldClass("request")

#' @importFrom rapiclient get_api get_operations get_schemas
#' @export
.Service <- setClass(
    "Service",
    slots = c(
        service = "character",
        config = "request",
        api = "rapi_api"
    )
)

.service <- function(x) x@service

.config <- function(x) x@config

.api <- function(x) x@api

.api_path <- function(service)
    system.file(package="AnVIL", "service", service, "api.json")

.authenticate_path <- function(service)
    system.file(package="AnVIL", "service", service, "auth.json")

Service <-
    function(service, host, config = httr::config())
{
    stopifnot(
        .is_scalar_character(service),
        .is_scalar_character(host)
    )

    config <- c(authenticate_config(service), config)

    api <- get_api(.api_path(service), config)
    api$schemes <- "https"
    api$host <- host

    .Service(service = service, config = config, api = api)
}

#' @export
setMethod(
    "operations", "Service",
    function(x)
{
    get_operations(.api(x))
})

#' @export
setMethod(
    "schemas", "Service",
    function(x)
{
    get_schemas(.api(x))
})

#' @rdname Service
#' @export
setMethod(
    "$", "Service",
    function(x, name)
{
    operations(x)[[name]]
})

#' @importFrom utils .DollarNames
#' @export
.DollarNames.Service <-
    function(x, pattern)
{
    grep(pattern, names(operations(x)), value = TRUE)
}

#' @export
setMethod(
    "show", "Service",
    function(object)
{
    cat(
        "service: ", .service(object), "\n",
        "operations() or ", tolower(class(object)), "$<tab completion> :\n",
        .pretty(names(operations(object)), 2, 2), "\n",
        "schemas():\n",
        .pretty(names(schemas(object)), 2, 2), "\n",
        sep=""
    )
})