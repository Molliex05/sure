module Assistant
  Error = Class.new(StandardError)

  REGISTRY = {
    "builtin" => Assistant::Builtin,
    "external" => Assistant::External
  }.freeze

  class << self
    def for_chat(chat)
      implementation_for(chat).for_chat(chat)
    end

    def config_for(chat)
      raise Error, "chat is required" if chat.blank?
      Assistant::Builtin.config_for(chat)
    end

    def available_types
      REGISTRY.keys
    end

    def function_classes
      [
        # Read
        Function::GetTransactions,
        Function::GetAccounts,
        Function::GetHoldings,
        Function::GetBalanceSheet,
        Function::GetIncomeStatement,
        Function::ImportBankStatement,
        Function::SearchFamilyFiles,
        # Write — categories & rules
        Function::SetCategory,
        Function::UpdateTransactionCategory,
        Function::CreateRule,
        # Write — Hermes memory
        Function::UpdateMemory,
        Function::UpdateUserProfile,
        # Read — metadata
        Function::GetCategories,
        Function::GetRules,
        Function::GetMerchants,
        # Write — transaction management
        Function::SetTransactionNote,
        Function::DeleteRule,
        Function::ExcludeTransaction,
        # Read — budgets
        Function::GetBudget,
        # Write — budgets
        Function::CreateBudget,
        Function::UpdateBudget,
        Function::DeleteBudget,
        Function::SetCategoryBudget
      ]
    end

    private

      def implementation_for(chat)
        raise Error, "chat is required" if chat.blank?
        type = ENV["ASSISTANT_TYPE"].presence || chat.user&.family&.assistant_type.presence || "builtin"
        REGISTRY.fetch(type) { REGISTRY["builtin"] }
      end
  end
end
