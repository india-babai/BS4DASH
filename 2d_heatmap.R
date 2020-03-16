# Lattice package
require(lattice)

# The volcano dataset is provided, it looks like that:
#head(volcano)

# 1: native palette from R
levelplot(volcano, col.regions = terrain.colors(100, alpha = 01)) # try cm.colors() or terrain.colors()

# 2: Rcolorbrewer palette
library(RColorBrewer)
coul <- colorRampPalette(brewer.pal(8, "PiYG"))(25)
levelplot(volcano, col.regions = coul) # try cm.colors() or terrain.colors()

# 3: Viridis
library(viridisLite)
coul <- viridis(100)
levelplot(volcano, col.regions = coul) 
#levelplot(volcano, col.regions = magma(100))