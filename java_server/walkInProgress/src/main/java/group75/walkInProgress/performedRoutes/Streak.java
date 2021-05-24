package group75.walkInProgress.performedRoutes;

import java.time.LocalDate;
import java.util.List;

public class Streak {
	private int days;
	private LocalDate startDate;
	private LocalDate endDate;
	List<PerformedRoute> routes;
	public Streak(int days, LocalDate startDate, LocalDate endDate, List<PerformedRoute> routes) {
		this.days = days;
		this.startDate = startDate;
		this.endDate = endDate;
		this.routes = routes;
	}
	public int getDays() {
		return days;
	}
	public LocalDate getStartDate() {
		return startDate;
	}
	public LocalDate getEndDate() {
		return endDate;
	}
	public List<PerformedRoute> getRoutes() {
		return routes;
	}
	@Override
	public String toString() {
		return "Streak [days=" + days + ", startDate=" + startDate + ", endDate=" + endDate + ", routes=" + routes
				+ "]";
	}
	
	

	
}
