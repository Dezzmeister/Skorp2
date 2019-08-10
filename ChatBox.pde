public class ChatBox {
  private ArrayList<String> messages = new ArrayList<String>();
  
  public TextField inputField;
  
  private PGraphics box;
  
  private int x, y, w, l;
  
  public ChatBox(int x, int y, int w, int l) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.l = l;
    
    box = createGraphics(w,l);
  }
}