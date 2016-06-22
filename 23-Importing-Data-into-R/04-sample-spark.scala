// Read CSV file
var path = "/Users/javierluraschi/RStudio/webinars/23-Importing-Data-into-R/data/"
var sourcePath = path + "Water_Right_Applications.csv"
var destPath = path + "Water_Right_Applications_Sample.csv"

val textFile = sc.textFile(sourcePath)

// Count number of rows
textFile.count()

// Retrieve a subset
val subset = textFile.takeSample(false, 100)

// Save subset
val pw = new java.io.PrintWriter(new java.io.File(destPath))
pw.write(subset.mkString("\n"))
pw.close