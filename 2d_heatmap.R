# Lattice package
require(lattice)

# The volcano dataset is provided, it looks like that:
#head(volcano)

# 1: native palette from R
levelplot(volcano, col.regions = terrain.colors(100, alpha = 01)) # try cm.colors() or terrain.colors()

# 2. Dual axis graph of LLR and Max of depth










