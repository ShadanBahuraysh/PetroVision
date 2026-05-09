# ========================================================================================================
# PetroVision Bronze Points Strategy
# --------------------------------------------------------------------------------------------------------
# This file defines the BronzePoints class used
# in the Strategy design pattern implementation
# within the PetroVision loyalty system.
#
# Features included:
# - Implementing the bronze membership reward strategy
# - Calculating loyalty points for bronze-tier customers
# - Providing the default point-calculation method
# - Supporting dynamic reward calculation
#
# It also provides a basic point-calculation
# strategy for standard loyalty membership users
# within the PetroVision platform.
# ========================================================================================================

from app.patterns.strategy.point_strategy import PointStrategy


class BronzePoints(PointStrategy):
    def calculate_points(self, amount):
        return int(amount)