public class State {
    public String label;
    public String value;
    public String dependingOn;

    public State(String label,String value, String dependingOn) {
        this.label = label;
        this.value = value;
        this.dependingOn = dependingOn;
    }
}
