## data-raw/datatypes/address.R
## Positive examples for the ADDRESS family. Street/city/state/zip parts seeded
## from the AutoType us-address files; PO-box examples synthesized (AutoType has
## no PO-box file). City-name positives are major cities present in the
## maps::us.cities lookup (smaller AutoType towns like "New Sharon" are not in
## the ~1,000-city list, by design). Composite `address` positives each carry a
## street + state + ZIP so they clear the 3-flag threshold regardless of city
## coverage.

street_address <- c(
  "2325 140th St", "303 Aspen Ct", "1225 S Walnut St", "30 Grandview Ct",
  "100 Main St", "742 Evergreen Terrace", "1600 Pennsylvania Ave",
  "221 Baker St", "350 Fifth Avenue", "500 College Ave", "1 Infinite Loop",
  "12 Oak Lane", "45 Elm Drive", "888 Sunset Boulevard", "77 Massachusetts Ave"
)

po_box <- c(
  "PO Box 1234", "P.O. Box 56", "POB 789", "Post Office Box 42", "PO BOX 100",
  "P.O.B. 12", "Po Box 9", "PostOffice Box 1500", "PO Box #45", "P O Box 7"
)

city_name <- c(
  "Chicago", "New Orleans", "Springfield", "Pittsburgh", "Bloomington",
  "Boston", "Seattle", "Portland", "Austin", "Denver", "Baltimore",
  "Cleveland", "Miami", "Atlanta", "Nashville", "New York", "Los Angeles"
)

city_state <- c(
  "Bloomington, IN", "Cheshire, CT", "Bloomington, Indiana", "Los Angeles, CA",
  "New York, NY", "Austin, TX", "Portland, Oregon", "Miami, FL",
  "Chicago, Illinois", "Seattle, WA", "Denver, Colorado", "Boston, MA"
)

state_zip <- c(
  "IN 47401", "CT, 06410", "Indiana 47401", "CA 90210", "TX 78701",
  "NY, 10001", "WA 98052", "Ohio 44512", "IL 60601", "MA 02108"
)

address <- c(
  "1225 S Walnut St, Bloomington, IN 47401",
  "30 Grandview Ct, Cheshire, CT 06410",
  "1600 Pennsylvania Ave, Washington, DC 20500",
  "350 Fifth Avenue, New York, NY 10118",
  "742 Evergreen Terrace, Springfield, IL 62704",
  "100 Main St, Boston, MA 02108",
  "221 Baker St, Chicago, IL 60601",
  "500 College Ave, Ithaca, NY 14850",
  "1 Infinite Loop, Cupertino, CA 95014",
  "77 Massachusetts Ave, Cambridge, MA 02139"
)
