# ========================================================================================================
# PetroVision Point Strategy Interface
# --------------------------------------------------------------------------------------------------------
# This file defines the abstract PointStrategy
# interface used in the Strategy design pattern
# implementation within the PetroVision loyalty system.
#
# Features included:
# - Defining a common point-calculation interface
# - Supporting multiple loyalty point strategies
# - Enforcing implementation of point calculation methods
# - Providing flexibility for tier-based reward systems
#
# It also allows different loyalty point calculation
# strategies (such as Bronze, Silver, and Gold tiers)
# to be implemented dynamically within the system.
# ========================================================================================================

from abc import ABC, abstractmethod


class PointStrategy(ABC):
    @abstractmethod
    def calculate_points(self, amount):
        pass