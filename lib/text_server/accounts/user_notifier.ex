defmodule TextServer.Accounts.UserNotifier do
  import Swoosh.Email

  alias TextServer.Mailer

  # Delivers the email using the application mailer.
  defp deliver(recipient, subject, body) do
    email =
      new()
      |> to(recipient)
      |> from({"Charles @ Ajax Multi-Commentary", "charles.pletcher@unil.ch"})
      |> subject(subject)
      |> text_body(body)

    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    end
  end

  # defp unsubscribe_url(email) do
  #   "https://opencommentaries.org/unsubscribe/#{email}"
  # end

  @doc """
  Deliver confirmation email with text fallback
  """
  def deliver_confirmation_email(user, url) do
    email =
      new()
      |> to(user.email)
      |> from({"Charles @ Ajax Multi-Commentary", "charles.pletcher@unil.ch"})
      |> subject("Please confirm your AjMC email address")
      |> html_body("""
      <tr>
        <td class="wrapper" style="font-family: sans-serif; font-size: 14px; vertical-align: top; box-sizing: border-box; padding: 20px;" valign="top">
            <table role="presentation" border="0" cellpadding="0" cellspacing="0" style="border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;" width="100%">
                <tr>
                    <td style="font-family: sans-serif; font-size: 14px; vertical-align: top;" valign="top">
                        <p style="font-family: sans-serif; font-size: 14px; font-weight: normal; margin: 0; margin-bottom: 15px;">Hi there,</p>
                        <p style="font-family: sans-serif; font-size: 14px; font-weight: normal; margin: 0; margin-bottom: 15px;">Please confirm your email address on <a href="#{url}">Ajax Multi-Commentary</a>.</p>
                        <table role="presentation" border="0" cellpadding="0" cellspacing="0" class="btn btn-primary" style="border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; box-sizing: border-box; width: 100%;" width="100%">
                            <tbody>
                                <tr>
                                    <td align="left" style="font-family: sans-serif; font-size: 14px; vertical-align: top; padding-bottom: 15px;" valign="top">
                                        <table role="presentation" border="0" cellpadding="0" cellspacing="0" style="border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: auto;">
                                            <tbody>
                                                <tr>
                                                    <td style="font-family: sans-serif; font-size: 14px; vertical-align: top; border-radius: 5px; text-align: center; background-color: #3498db;" valign="top" align="center" bgcolor="#3498db"> <a href="<%= @url %>" target="_blank" style="border: solid 1px #3498db; border-radius: 5px; box-sizing: border-box; cursor: pointer; display: inline-block; font-size: 14px; font-weight: bold; margin: 0; padding: 12px 25px; text-decoration: none; text-transform: capitalize; background-color: #3498db; border-color: #3498db; color: #ffffff;">Confirm</a> </td>
                                                </tr>
                                            </tbody>
                                        </table>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                        <p style="font-family: sans-serif; font-size: 14px; font-weight: normal; margin: 0; margin-bottom: 15px;">If the above link isn&apos;t working for you, you can copy-paste the following URL into your browser:</p>
                        <p style="font-family: sans-serif; font-size: 14px; font-weight: normal; margin: 0; margin-bottom: 15px;">#{url}</p>
                    </td>
                </tr>
            </table>
        </td>
      </tr>
      """)
      |> text_body(confirmation_instructions_text(user.email, url))

    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    end
  end

  def confirmation_instructions_text(email, url) do
    """

    ==============================

    Hi #{email},

    Please confirm your Ajax Multi-Commentary account by visiting the URL below:

    #{url}

    If you didn't create an account with us, please ignore this email.

    ==============================
    """
  end

  @doc """
  Deliver instructions to reset a user password.
  """
  def deliver_reset_password_instructions(user, url) do
    deliver(user.email, "Ajax Multi-Commentary reset password instructions", """

    ==============================

    Hi #{user.email},

    You can reset your Ajax Multi-Commentary password by visiting the URL below:

    #{url}

    If you didn't request this change, please ignore this email.

    ==============================
    """)
  end

  @doc """
  Deliver instructions to update a user email.
  """
  def deliver_update_email_instructions(user, url) do
    deliver(user.email, "Ajax Multi-Commentary update email instructions", """

    ==============================

    Hi #{user.email},

    You can change your Ajax Multi-Commentary email by visiting the URL below:

    #{url}

    If you didn't request this change, please ignore this email.

    ==============================
    """)
  end
end
