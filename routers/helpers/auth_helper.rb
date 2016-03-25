module AuthHelper
  def require_auth!
    if admin?
      @checkpoints = ChiScore::Checkpoints._collection
    elsif checkpoint?
      @checkpoint = ChiScore::Checkpoints.find(session['checkpoint-id'])
    else
      redirect_to_login
    end
  end

  def require_admin!
    redirect_to_login unless admin?
  end

  def admin?
    session['admin'] == ChiScore::Auth.admin_key
  end

  def checkpoint?
    !session['checkpoint-id'].nil?
  end

  def logged_in?
    admin? || checkpoint?
  end
end
