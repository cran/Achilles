% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/exportToJson.R
\name{showReportTypes}
\alias{showReportTypes}
\title{showReportTypes}
\usage{
showReportTypes()
}
\value{
none (opens the allReports vector in a View() display)
}
\description{
\code{showReportTypes} Displays the Report Types that can be passed as vector values to
exportToJson.
}
\details{
exportToJson supports the following report types: "CONDITION","CONDITION_ERA", "DASHBOARD",
"DATA_DENSITY", "DEATH", "DRUG", "DRUG_ERA", "META", "OBSERVATION", "OBSERVATION_PERIOD", "PERSON",
"PROCEDURE","VISIT"
}
\examples{
\dontrun{
showReportTypes()
}
}
