class SessionDataRepository < Hanami::Repository
  def has_graph?(session_id)
    !session_data.where(id: session_id).where { graph_data.not(nil) }.count.zero?
  end

  def graph_for_id(session_id)
    session_data.where(id: session_id).pluck(:graph_data).first
  end

  def exists?(session_id)
    !session_data.where(id: session_id).count.zero?
  end

  def create_if_new(session_id)
    return if exists?(session_id)

    create(id: session_id)
  end

  def touch_record(session_id)
    update(session_id, updated_at: Time.now)
  end
end
