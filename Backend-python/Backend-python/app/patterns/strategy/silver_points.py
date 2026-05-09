# ========================================================================================================
# PetroVision Silver Points Strategy
# --------------------------------------------------------------------------------------------------------
# This file defines the SilverPoints class used
# in the Strategy design pattern implementation
# within the PetroVision loyalty system.
#
# Features included:
# - Implementing the silver membership reward strategy
# - Calculating loyalty points for silver-tier customers
# - Applying bonus point multipliers
# - Supporting dynamic reward calculation
#
# It also provides a specialized point-calculation
# strategy for silver membership users within
# the PetroVision loyalty platform.
# ========================================================================================================

from app.patterns.strategy.point_strategy import PointStrategy


class SilverPoints(PointStrategy):
    def calculate_points(self, amount):
        return int(amount * 1.25)