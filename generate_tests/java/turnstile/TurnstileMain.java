import thejava.turnstile.*;

public class TurnstileMain implements JavaTurnstileContext
{
  public void unlock()
  {
    System.out.println("unlocked");
  }

  public void alarm()
  {
    System.out.println("BUZZ BUZZ");
  }

  public void thanks()
  {
    System.out.println("Why thank you!");
  }

  public void lock()
  {
    System.out.println("locked!");
  }

  public static void main(String[] args)
  {
    JavaTurnstile sm = new JavaTurnstile(new TurnstileMain());
    sm.pass();
    sm.coin();
    sm.coin();
    sm.coin();
    sm.pass();
  }
}
