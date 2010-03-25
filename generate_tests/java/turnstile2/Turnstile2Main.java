import thejava.turnstile.*;

public class Turnstile2Main implements JavaTurnstileContext
{
  public void unlock()
  {
    System.out.println("unlock");
  }

  public void alarm()
  {
    System.out.println("alarm");
  }

  public void thanks()
  {
    System.out.println("thanks");
  }

  public void lock()
  {
    System.out.println("lock");
  }

  public void operate()
  {
    System.out.println("operate");
  }

  public void disable()
  {
    System.out.println("disable");
  }

  public void beep()
  {
    System.out.println("beep");
  }

  public static void main(String[] args)
  {
    JavaTurnstile sm = new JavaTurnstile(new Turnstile2Main());
    sm.pass();
    sm.coin();
    sm.coin();
    sm.pass();
    sm.diagnose();
    sm.operate();
    sm.coin();
    sm.pass();
  }
}
