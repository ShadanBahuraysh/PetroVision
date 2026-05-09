# ========================================================================================================
# PetroVision Gold Points Strategy
# --------------------------------------------------------------------------------------------------------
# This file defines the GoldPoints class used
# in the Strategy design pattern implementation
# within the PetroVision loyalty system.
#
# Features included:
# - Implementing the gold membership reward strategy
# - Calculating loyalty points for gold-tier customers
# - Applying premium bonus point multipliers
# - Supporting dynamic reward calculation
#
# It also provides an advanced point-calculation
# strategy for premium loyalty membership users
# within the PetroVision platform.
# ========================================================================================================

from app.patterns.strategy.point_strategy import PointStrategy


class GoldPoints(PointStrategy):
    def calculate_points(self, amount):
        return int(amount * 1.5)