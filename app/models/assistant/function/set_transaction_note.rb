class Assistant::Function::SetTransactionNote < Assistant::Function
  def self.name
    "set_transaction_note"
  end

  def self.description
    "Add or update the note on a transaction. Use this to add context, flag something unusual, or document why a transaction was categorized a certain way."
  end

  def call(params = {})
    transaction_id = params["transaction_id"]
    note = params["note"]

    return { success: false, error: "transaction_id is required" } if transaction_id.blank?
    return { success: false, error: "note is required" } if note.nil?

    txn = family.transactions.with_entry.find_by(id: transaction_id)
    return { success: false, error: "Transaction not found" } unless txn

    txn.entry.update!(notes: note.presence)
    { success: true, transaction_id: transaction_id }
  rescue ActiveRecord::RecordInvalid => e
    { success: false, error: e.message }
  end

  def params_schema
    build_schema(
      properties: {
        "transaction_id" => { type: "string", description: "UUID of the transaction" },
        "note" => { type: "string", description: "Note to add. Pass empty string to clear the note." }
      },
      required: [ "transaction_id", "note" ]
    )
  end
end
