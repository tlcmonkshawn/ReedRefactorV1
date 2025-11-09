# FinalizationService - Finalizes Booties to Square catalog
#
# Handles the finalization process that publishes Booties to the Square e-commerce catalog.
# Finalization is the last step in the Bootie workflow - once finalized, the Bootie
# appears in the online store and is available for purchase.
#
# Finalization Process:
# 1. Verify user has permission to finalize (Bootie Boss or Admin)
# 2. Verify Bootie is in "researched" status
# 3. Verify final_bounty is provided
# 4. Create product in Square catalog via SquareCatalogService
# 5. Update Bootie with Square product IDs and final bounty
# 6. Update Bootie status to "finalized"
#
# Only Bootie Bosses and Admins can finalize Booties.
#
# @see PRODUCT_PROFILE.md for finalization feature details
# @see SquareCatalogService for Square integration
class FinalizationService < ApplicationService
  # Initialize service with Bootie, user, and final bounty
  #
  # @param bootie [Bootie] The Bootie to finalize
  # @param user [User] The user attempting to finalize (must be Bootie Boss or Admin)
  # @param final_bounty [Decimal] Final price set by Bootie Boss
  def initialize(bootie:, user:, final_bounty:)
    @bootie = bootie
    @user = user
    @final_bounty = final_bounty
  end

  # Execute finalization process
  #
  # @return [ServiceResult] Result with finalized Bootie on success, error on failure
  def call
    return failure("User cannot finalize Booties") unless @user.can_finalize?
    return failure("Bootie not ready for finalization") unless @bootie.researched?
    return failure("Final bounty is required") if @final_bounty.blank?

    # Create product in Square catalog via Square MCP
    square_result = SquareCatalogService.new.create_product(@bootie)
    return square_result if square_result.failure?

    # Update Bootie with Square product IDs and final bounty
    # This also updates status to "finalized" and sets finalized_at timestamp
    @bootie.finalize!(
      final_bounty: @final_bounty,
      square_product_id: square_result.data[:product_id],
      square_variation_id: square_result.data[:variation_id]
    )

    success(@bootie)
  end
end

