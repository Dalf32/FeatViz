Hanami::Model.migration do
  change do
    run(<<~QUERY
      CREATE TRIGGER clear_old_sessions
        AFTER INSERT ON session_data
      BEGIN
        DELETE FROM session_data WHERE updated_at < DATETIME('now', '-7 days');
      END;
    QUERY
    )
  end
end
