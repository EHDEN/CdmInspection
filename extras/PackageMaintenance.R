# @file PackageMaintenance.R
#
# Copyright 2020 European Health Data and Evidence Network (EHDEN)
#
# This file is part of CatalogueExport
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# @author European Health Data and Evidence Network
# @author Peter Rijnbeek

# Manually delete package from library. Avoids "Already in use" message when rebuilding
unloadNamespace("CdmInspection")
.rs.restartR()
folder <- system.file(package = "CdmInspection")
folder
unlink(folder, recursive = TRUE, force = TRUE)
file.exists(folder)

# Format and check code:
OhdsiRTools::formatRFolder()
OhdsiRTools::checkUsagePackage("CdmInspection")
OhdsiRTools::updateCopyrightYearFolder()
OhdsiRTools::findNonAsciiStringsInFolder()
devtools::spell_check()

# Create manual and vignettes:
unlink("extras/CdmInspection.pdf")
system("R CMD Rd2pdf ./ --output=extras/CdmInspection.pdf")
