"""
F1 Database Management System 
"""

import streamlit as st
import mysql.connector
import pandas as pd
from mysql.connector import Error
import plotly.express as px
import plotly.graph_objects as go
from datetime import datetime

# =============================================================
# PAGE CONFIGURATION
# =============================================================
st.set_page_config(
    page_title="F1 Database Manager",
    page_icon="🏎",
    layout="wide",
    initial_sidebar_state="expanded"
)

# =============================================================
# DATABASE CONNECTION
# =============================================================
@st.cache_resource
def get_connection():
    """Create MySQL database connection"""
    try:
        connection = mysql.connector.connect(
            host='localhost',
            user='root',  # Change to your username
            password='suhkan@2019',  # CHANGE THIS TO YOUR PASSWORD
            database='f1_db'
        )
        return connection
    except Error as e:
        st.error(f"❌ Database connection failed: {e}")
        return None

def execute_query(query, params=None, fetch=True):
    """Execute SQL query"""
    conn = get_connection()
    if conn is None:
        return None
    
    try:
        cursor = conn.cursor(dictionary=True)
        cursor.execute(query, params or ())
        
        if fetch:
            result = cursor.fetchall()
            cursor.close()
            return result
        else:
            conn.commit()
            cursor.close()
            return True
    except Error as e:
        st.error(f"❌ Query failed: {e}")
        return None

def call_procedure(proc_name, params=()):
    """Call stored procedure"""
    conn = get_connection()
    if conn is None:
        return None
    
    try:
        cursor = conn.cursor(dictionary=True)
        cursor.callproc(proc_name, params)
        
        results = []
        for result in cursor.stored_results():
            results.extend(result.fetchall())
        
        cursor.close()
        return results
    except Error as e:
        st.error(f"❌ Procedure failed: {e}")
        return None

# =============================================================
# MAIN UI
# =============================================================

# Title and Header
st.title("🏎 Formula 1 Database Management System")
st.markdown("### Lab-09 Demonstration: Triggers, Procedures, Functions & Queries")
st.divider()

# Sidebar Navigation
with st.sidebar:
    st.image("https://upload.wikimedia.org/wikipedia/commons/3/33/F1.svg", width=150)
    st.header("Navigation")
    
    page = st.radio(
        "Select Page:",
        [
            "🏠 Dashboard",
            "🏆 Championship Standings",
            "👤 Driver Management",
            "🏢 Team Management",
            "🏁 Race Results",
            "📊 Analytics",
            "⚙ Database Operations",
            "📜 Audit Log"
        ]
    )
    
    st.divider()
    st.info("**Database:** f1_db\n**Status:** ✅ Connected")

# =============================================================
# PAGE: DASHBOARD
# =============================================================
if page == "🏠 Dashboard":
    st.header("📊 Dashboard")
    
    # Statistics Cards
    col1, col2, col3, col4 = st.columns(4)
    
    with col1:
        driver_count = execute_query("SELECT COUNT(*) as count FROM DRIVER")[0]['count']
        st.metric("Total Drivers", driver_count, "Active")
    
    with col2:
        team_count = execute_query("SELECT COUNT(*) as count FROM TEAM")[0]['count']
        st.metric("Total Teams", team_count, "2024 Season")
    
    with col3:
        race_count = execute_query("SELECT COUNT(*) as count FROM RACE")[0]['count']
        st.metric("Total Races", race_count, "Completed")
    
    with col4:
        result_count = execute_query("SELECT COUNT(*) as count FROM RESULT")[0]['count']
        st.metric("Total Results", result_count, "Recorded")
    
    st.divider()
    
    # Top 5 Drivers
    col1, col2 = st.columns(2)
    
    with col1:
        st.subheader("🏆 Top 5 Drivers")
        query = """
        SELECT 
            CONCAT(D.First_Name, ' ', D.Last_Name) AS Driver,
            T.Team_Name,
            SUM(R.Points) AS Points,
            COUNT(CASE WHEN R.Position = 1 THEN 1 END) AS Wins
        FROM DRIVER D
        JOIN RESULT R ON D.Driver_ID = R.Driver_ID
        JOIN TEAM T ON R.Team_ID = T.Team_ID
        GROUP BY D.Driver_ID, D.First_Name, D.Last_Name, T.Team_Name
        ORDER BY Points DESC
        LIMIT 5
        """
        top_drivers = pd.DataFrame(execute_query(query))
        st.dataframe(top_drivers, use_container_width=True, hide_index=True)
    
    with col2:
        st.subheader("🏢 Top 5 Teams")
        query = """
        SELECT 
            T.Team_Name,
            SUM(R.Points) AS Points,
            COUNT(CASE WHEN R.Position = 1 THEN 1 END) AS Wins
        FROM TEAM T
        JOIN RESULT R ON T.Team_ID = R.Team_ID
        GROUP BY T.Team_ID, T.Team_Name
        ORDER BY Points DESC
        LIMIT 5
        """
        top_teams = pd.DataFrame(execute_query(query))
        st.dataframe(top_teams, use_container_width=True, hide_index=True)
    
    st.divider()
    
    # Recent Races
    st.subheader("🏁 Recent Races")
    query = """
    SELECT 
        RA.Race_Name,
        RA.Venue,
        C.Circuit_Name,
        RA.Year,
        CONCAT(D.First_Name, ' ', D.Last_Name) AS Winner
    FROM RACE RA
    JOIN CIRCUIT C ON RA.Circuit_ID = C.Circuit_ID
    LEFT JOIN RESULT RES ON RA.Race_ID = RES.Race_ID AND RES.Position = 1
    LEFT JOIN DRIVER D ON RES.Driver_ID = D.Driver_ID
    ORDER BY RA.Race_ID DESC
    LIMIT 5
    """
    recent_races = pd.DataFrame(execute_query(query))
    st.dataframe(recent_races, use_container_width=True, hide_index=True)

# =============================================================
# PAGE: CHAMPIONSHIP STANDINGS
# =============================================================
elif page == "🏆 Championship Standings":
    st.header("🏆 Championship Standings")
    
    tab1, tab2 = st.tabs(["Driver Standings", "Team Standings"])
    
    with tab1:
        st.subheader("Driver Championship 2024")
        
        # Call stored procedure
        standings = call_procedure('GetChampionshipStandings', (2024,))
        if standings:
            df = pd.DataFrame(standings)
            
            # Add rank column
            df.insert(0, 'Rank', range(1, len(df) + 1))
            
            st.dataframe(df, use_container_width=True, hide_index=True)
            
            # Chart
            fig = px.bar(
                df.head(10),
                x='Driver_Name',
                y='Total_Points',
                color='Team_Name',
                title='Top 10 Drivers by Points',
                labels={'Total_Points': 'Points', 'Driver_Name': 'Driver'}
            )
            st.plotly_chart(fig, use_container_width=True)
    
    with tab2:
        st.subheader("Team Championship 2024")
        
        query = """
        SELECT 
            T.Team_Name,
            T.Nationality,
            SUM(R.Points) AS Total_Points,
            COUNT(CASE WHEN R.Position = 1 THEN 1 END) AS Wins,
            COUNT(CASE WHEN R.Position <= 3 THEN 1 END) AS Podiums
        FROM TEAM T
        JOIN RESULT R ON T.Team_ID = R.Team_ID
        JOIN RACE RA ON R.Race_ID = RA.Race_ID
        WHERE RA.Year = 2024
        GROUP BY T.Team_ID, T.Team_Name, T.Nationality
        ORDER BY Total_Points DESC
        """
        team_standings = pd.DataFrame(execute_query(query))
        team_standings.insert(0, 'Rank', range(1, len(team_standings) + 1))
        
        st.dataframe(team_standings, use_container_width=True, hide_index=True)
        
        # Chart
        fig = px.bar(
            team_standings,
            x='Team_Name',
            y='Total_Points',
            color='Nationality',
            title='Team Championship Points',
            labels={'Total_Points': 'Points', 'Team_Name': 'Team'}
        )
        st.plotly_chart(fig, use_container_width=True)

# =============================================================
# PAGE: DRIVER MANAGEMENT
# =============================================================
elif page == "👤 Driver Management":
    st.header("👤 Driver Management")
    
    tab1, tab2, tab3 = st.tabs(["View Drivers", "Driver Stats", "Add Driver"])
    
    with tab1:
        st.subheader("All Drivers")
        query = """
        SELECT 
            D.Driver_ID,
            CONCAT(D.First_Name, ' ', D.Last_Name) AS Driver_Name,
            D.DOB,
            TIMESTAMPDIFF(YEAR, D.DOB, CURDATE()) AS Age,
            T.Team_Name
        FROM DRIVER D
        LEFT JOIN TEAM T ON D.Team_ID = T.Team_ID
        ORDER BY D.Driver_ID
        """
        drivers = pd.DataFrame(execute_query(query))
        st.dataframe(drivers, use_container_width=True, hide_index=True)
    
    with tab2:
        st.subheader("Driver Statistics")
        
        # Select driver
        driver_query = "SELECT Driver_ID, CONCAT(First_Name, ' ', Last_Name) as Name FROM DRIVER ORDER BY First_Name"
        drivers_list = execute_query(driver_query)
        driver_options = {d['Name']: d['Driver_ID'] for d in drivers_list}
        
        selected_driver = st.selectbox("Select Driver:", list(driver_options.keys()))
        
        if st.button("Get Stats"):
            driver_id = driver_options[selected_driver]
            stats = call_procedure('GetDriverStats', (driver_id,))
            
            if stats:
                df = pd.DataFrame(stats)
                
                # Display as metrics
                col1, col2, col3, col4 = st.columns(4)
                with col1:
                    st.metric("Total Points", df['Total_Points'].values[0])
                with col2:
                    st.metric("Wins", df['Wins'].values[0])
                with col3:
                    st.metric("Podiums", df['Podiums'].values[0])
                with col4:
                    best = df['Best_Finish'].values[0]
                    st.metric("Best Finish", f"P{int(best)}" if best else "N/A")
                
                st.dataframe(df, use_container_width=True, hide_index=True)
    
    with tab3:
        st.subheader("Add New Driver")
        
        with st.form("add_driver_form"):
            first_name = st.text_input("First Name")
            last_name = st.text_input("Last Name")
            dob = st.date_input("Date of Birth", max_value=datetime.now().date())
            
            # Get teams
            teams = execute_query("SELECT Team_ID, Team_Name FROM TEAM ORDER BY Team_Name")
            team_options = {t['Team_Name']: t['Team_ID'] for t in teams}
            selected_team = st.selectbox("Team:", list(team_options.keys()))
            
            submitted = st.form_submit_button("Add Driver")
            
            if submitted:
                team_id = team_options[selected_team]
                result = call_procedure('AddDriver', (first_name, last_name, dob, team_id))
                if result:
                    st.success(f"✅ Driver {first_name} {last_name} added successfully!")
                    st.rerun()

# =============================================================
# PAGE: TEAM MANAGEMENT
# =============================================================
elif page == "🏢 Team Management":
    st.header("🏢 Team Management")
    
    tab1, tab2 = st.tabs(["View Teams", "Team Performance"])
    
    with tab1:
        st.subheader("All Teams")
        query = "SELECT * FROM TEAM ORDER BY Team_Name"
        teams = pd.DataFrame(execute_query(query))
        st.dataframe(teams, use_container_width=True, hide_index=True)
    
    with tab2:
        st.subheader("Team Performance Analysis")
        
        teams = execute_query("SELECT Team_ID, Team_Name FROM TEAM ORDER BY Team_Name")
        team_options = {t['Team_Name']: t['Team_ID'] for t in teams}
        
        selected_team = st.selectbox("Select Team:", list(team_options.keys()))
        
        if st.button("Get Performance"):
            team_id = team_options[selected_team]
            perf = call_procedure('GetTeamPerformance', (team_id,))
            
            if perf:
                df = pd.DataFrame(perf)
                
                col1, col2, col3 = st.columns(3)
                with col1:
                    st.metric("Total Points", df['Total_Points'].values[0])
                with col2:
                    st.metric("Wins", df['Wins'].values[0])
                with col3:
                    st.metric("Podiums", df['Podiums'].values[0])
                
                st.dataframe(df, use_container_width=True, hide_index=True)

# =============================================================
# PAGE: RACE RESULTS
# =============================================================
elif page == "🏁 Race Results":
    st.header("🏁 Race Results")
    
    # Get races
    races = execute_query("SELECT Race_ID, CONCAT(Race_Name, ' - ', Year) as Race_Display FROM RACE ORDER BY Race_ID DESC")
    race_options = {r['Race_Display']: r['Race_ID'] for r in races}
    
    selected_race = st.selectbox("Select Race:", list(race_options.keys()))
    
    if st.button("Show Results", type="primary"):
        race_id = race_options[selected_race]
        results = call_procedure('GetRaceResults', (race_id,))
        
        if results:
            df = pd.DataFrame(results)
            
            # Style the dataframe
            st.dataframe(
                df,
                use_container_width=True,
                hide_index=True,
                column_config={
                    "Position": st.column_config.NumberColumn("Pos", format="%d"),
                    "Points": st.column_config.NumberColumn("Points", format="%.1f"),
                }
            )
            
            # Podium visualization
            podium_df = df[df['Position'].notna() & (df['Position'] <= 3)]
            if not podium_df.empty:
                st.subheader("🏆 Podium")
                col1, col2, col3 = st.columns(3)
                
                if len(podium_df) >= 1:
                    with col1:
                        st.markdown("### 🥇 1st Place")
                        st.success(f"{podium_df.iloc[0]['Driver_Name']}")
                        st.write(f"Team: {podium_df.iloc[0]['Team_Name']}")
                        st.write(f"Points: {podium_df.iloc[0]['Points']}")
                
                if len(podium_df) >= 2:
                    with col2:
                        st.markdown("### 🥈 2nd Place")
                        st.info(f"{podium_df.iloc[1]['Driver_Name']}")
                        st.write(f"Team: {podium_df.iloc[1]['Team_Name']}")
                        st.write(f"Points: {podium_df.iloc[1]['Points']}")
                
                if len(podium_df) >= 3:
                    with col3:
                        st.markdown("### 🥉 3rd Place")
                        st.warning(f"{podium_df.iloc[2]['Driver_Name']}")
                        st.write(f"Team: {podium_df.iloc[2]['Team_Name']}")
                        st.write(f"Points: {podium_df.iloc[2]['Points']}")

# =============================================================
# PAGE: ANALYTICS (FIXED)
# =============================================================
elif page == "📊 Analytics":
    st.header("📊 Advanced Analytics")
    
    tab1, tab2, tab3 = st.tabs(["Circuit Analysis", "DNF Analysis", "Points Distribution"])
    
    with tab1:
        st.subheader("Circuit Statistics")
        query = """
        SELECT
            C.Circuit_Name,
            C.Location,
            COUNT(DISTINCT RA.Race_ID) AS Races_Held,
            ROUND(AVG(RES.Points), 2) AS Avg_Points
        FROM CIRCUIT C
        JOIN RACE RA ON C.Circuit_ID = RA.Circuit_ID
        LEFT JOIN RESULT RES ON RA.Race_ID = RES.Race_ID
        GROUP BY C.Circuit_ID, C.Circuit_Name, C.Location
        ORDER BY Races_Held DESC
        """
        circuit_data = pd.DataFrame(execute_query(query))
        st.dataframe(circuit_data, use_container_width=True, hide_index=True)
        
        # Chart - FIXED: Changed from update_xaxis to update_layout
        fig = px.bar(
            circuit_data,
            x='Circuit_Name',
            y='Races_Held',
            color='Location',
            title='Races Held per Circuit'
        )
        fig.update_layout(xaxis_tickangle=-45)  # FIXED LINE
        st.plotly_chart(fig, use_container_width=True)
    
    with tab2:
        st.subheader("DNF (Did Not Finish) Analysis")
        query = """
        SELECT
            T.Team_Name,
            COUNT(RES.Result_ID) AS Total_Results,
            SUM(CASE WHEN S.Status_description = 'Finished' THEN 1 ELSE 0 END) AS Finished,
            SUM(CASE WHEN S.Status_description != 'Finished' THEN 1 ELSE 0 END) AS DNF,
            ROUND(
                (SUM(CASE WHEN S.Status_description = 'Finished' THEN 1 ELSE 0 END) * 100.0) / COUNT(RES.Result_ID),
                2
            ) AS Reliability_Percentage
        FROM TEAM T
        JOIN RESULT RES ON T.Team_ID = RES.Team_ID
        JOIN STATUS S ON RES.Status_ID = S.Status_ID
        GROUP BY T.Team_ID, T.Team_Name
        ORDER BY Reliability_Percentage DESC
        """
        dnf_data = pd.DataFrame(execute_query(query))
        st.dataframe(dnf_data, use_container_width=True, hide_index=True)
        
        # Chart
        fig = go.Figure()
        fig.add_trace(go.Bar(
            name='Finished',
            x=dnf_data['Team_Name'],
            y=dnf_data['Finished'],
            marker_color='green'
        ))
        fig.add_trace(go.Bar(
            name='DNF',
            x=dnf_data['Team_Name'],
            y=dnf_data['DNF'],
            marker_color='red'
        ))
        fig.update_layout(
            barmode='stack',
            title='Team Reliability Analysis',
            xaxis_tickangle=-45
        )
        st.plotly_chart(fig, use_container_width=True)
    
    with tab3:
        st.subheader("Points Distribution")
        query = """
        SELECT
            CONCAT(D.First_Name, ' ', D.Last_Name) AS Driver_Name,
            SUM(R.Points) AS Total_Points
        FROM DRIVER D
        JOIN RESULT R ON D.Driver_ID = R.Driver_ID
        GROUP BY D.Driver_ID, D.First_Name, D.Last_Name
        HAVING Total_Points > 0
        ORDER BY Total_Points DESC
        """
        points_data = pd.DataFrame(execute_query(query))
        
        # Pie chart
        fig = px.pie(
            points_data.head(10),
            values='Total_Points',
            names='Driver_Name',
            title='Top 10 Drivers - Points Share'
        )
        st.plotly_chart(fig, use_container_width=True)

# =============================================================
# PAGE: DATABASE OPERATIONS (FIXED)
# =============================================================
elif page == "⚙ Database Operations":
    st.header("⚙ Database Operations")
    
    tab1, tab2, tab3 = st.tabs(["Test Functions", "Test Queries", "Add Result"])
    
    with tab1:
        st.subheader("Test Database Functions")
        
        col1, col2 = st.columns(2)
        
        with col1:
            st.markdown("**Driver Functions**")
            driver_id = st.number_input("Driver ID:", min_value=1, value=1)
            
            if st.button("Test Driver Functions"):
                query = f"""
                SELECT
                    GetDriverTotalPoints({driver_id}) AS Total_Points,
                    CountDriverWins({driver_id}) AS Wins,
                    GetDriverAge({driver_id}) AS Age,
                    GetBestFinish({driver_id}) AS Best_Finish
                """
                result = execute_query(query)
                if result:
                    st.json(result[0])
        
        with col2:
            st.markdown("**Team Functions**")
            team_id = st.number_input("Team ID:", min_value=1, value=1)
            
            if st.button("Test Team Functions"):
                query = f"""
                SELECT
                    GetTeamTotalPoints({team_id}) AS Total_Points,
                    CountTeamWins({team_id}) AS Wins
                """
                result = execute_query(query)
                if result:
                    st.json(result[0])
    
    with tab2:
        st.subheader("Complex Queries Demonstration")
        
        # ***** MODIFICATION 1 (Added Nested Query) *****
        query_type = st.selectbox(
            "Select Query:",
            [
                "Top Drivers by Points",
                "Team Performance Comparison",
                "Race Winners Summary",
                "Circuit Statistics",
                "Drivers with No Points (Nested Query)"  # <-- MODIFIED
            ]
        )
        
        if st.button("Execute Query"):
            if query_type == "Top Drivers by Points":
                query = """
                SELECT
                    CONCAT(D.First_Name, ' ', D.Last_Name) AS Driver_Name,
                    T.Team_Name,
                    GetDriverTotalPoints(D.Driver_ID) AS Total_Points,
                    CountDriverWins(D.Driver_ID) AS Wins,
                    GetBestFinish(D.Driver_ID) AS Best_Finish,
                    GetDriverAge(D.Driver_ID) AS Age
                FROM DRIVER D
                LEFT JOIN TEAM T ON D.Team_ID = T.Team_ID
                ORDER BY Total_Points DESC
                LIMIT 10
                """
            elif query_type == "Team Performance Comparison":
                query = """
                SELECT
                    T.Team_Name,
                    GetTeamTotalPoints(T.Team_ID) AS Total_Points,
                    CountTeamWins(T.Team_ID) AS Wins,
                    COUNT(DISTINCT R.Driver_ID) AS Different_Drivers
                FROM TEAM T
                LEFT JOIN RESULT R ON T.Team_ID = R.Team_ID
                GROUP BY T.Team_ID, T.Team_Name
                ORDER BY Total_Points DESC
                """
            elif query_type == "Race Winners Summary":
                query = """
                SELECT
                    RA.Race_Name,
                    RA.Year,
                    CONCAT(D.First_Name, ' ', D.Last_Name) AS Winner,
                    T.Team_Name,
                    RES.Points
                FROM RACE RA
                JOIN RESULT RES ON RA.Race_ID = RES.Race_ID AND RES.Position = 1
                JOIN DRIVER D ON RES.Driver_ID = D.Driver_ID
                JOIN TEAM T ON RES.Team_ID = T.Team_ID
                ORDER BY RA.Race_ID DESC
                """
            
            # ***** MODIFICATION 2 (Added Nested Query Logic) *****
            elif query_type == "Drivers with No Points (Nested Query)":
                st.info("This query demonstrates a nested query (subquery) to find drivers who are not in the set of drivers that have scored points.")
                query = """
                SELECT First_Name, Last_Name
                FROM DRIVER
                WHERE Driver_ID NOT IN (
                    -- This is the nested query --
                    SELECT DISTINCT Driver_ID
                    FROM RESULT
                    WHERE Points > 0
                )
                ORDER BY Last_Name;
                """
            # ***** END OF MODIFICATION 2 *****
            
            else:  # Circuit Statistics
                query = """
                SELECT
                    C.Circuit_Name,
                    C.Location,
                    COUNT(DISTINCT RA.Race_ID) AS Races_Held
                FROM CIRCUIT C
                LEFT JOIN RACE RA ON C.Circuit_ID = RA.Circuit_ID
                GROUP BY C.Circuit_ID, C.Circuit_Name, C.Location
                ORDER BY Races_Held DESC
                """
            
            result = execute_query(query)
            if result:
                df = pd.DataFrame(result)
                st.dataframe(df, use_container_width=True, hide_index=True)
    
    with tab3:
        st.subheader("Add Race Result")
        
        with st.form("add_result_form"):
            # Get races
            races = execute_query("SELECT Race_ID, CONCAT(Race_Name, ' - ', Year) as Display FROM RACE")
            race_opts = {r['Display']: r['Race_ID'] for r in races}
            sel_race = st.selectbox("Race:", list(race_opts.keys()))
            
            # Get drivers
            drivers = execute_query("SELECT Driver_ID, CONCAT(First_Name, ' ', Last_Name) as Name FROM DRIVER")
            driver_opts = {d['Name']: d['Driver_ID'] for d in drivers}
            sel_driver = st.selectbox("Driver:", list(driver_opts.keys()))
            
            # Get teams
            teams = execute_query("SELECT Team_ID, Team_Name FROM TEAM")
            team_opts = {t['Team_Name']: t['Team_ID'] for t in teams}
            sel_team = st.selectbox("Team:", list(team_opts.keys()))
            
            # Get status
            statuses = execute_query("SELECT Status_ID, Status_description FROM STATUS")
            status_opts = {s['Status_description']: s['Status_ID'] for s in statuses}
            sel_status = st.selectbox("Status:", list(status_opts.keys()))
            
            position = st.number_input("Final Position (leave 0 for DNF):", min_value=0, max_value=20, value=1)
            grid = st.number_input("Grid Position:", min_value=1, max_value=20, value=1)
            points = st.number_input("Points:", min_value=0.0, max_value=26.0, value=0.0, step=1.0)
            
            submitted = st.form_submit_button("Add Result")
            
            if submitted:
                race_id = race_opts[sel_race]
                driver_id = driver_opts[sel_driver]
                team_id = team_opts[sel_team]
                status_id = status_opts[sel_status]
                final_pos = position if position > 0 else None
                
                result = call_procedure('AddRaceResult', (race_id, driver_id, team_id, status_id, final_pos, grid, points))
                if result:
                    st.success("✅ Race result added successfully!")
                    st.rerun()

# =============================================================
# PAGE: AUDIT LOG
# =============================================================
elif page == "📜 Audit Log":
    st.header("📜 Audit Log")
    
    st.info("This page shows all database changes tracked by triggers")
    
    query = """
    SELECT
        Log_ID,
        Table_Name,
        Action,
        Record_ID,
        Old_Value,
        New_Value,
        Changed_By,
        Changed_At
    FROM AUDIT_LOG
    ORDER BY Changed_At DESC
    LIMIT 50
    """
    
    audit_data = execute_query(query)
    if audit_data:
        df = pd.DataFrame(audit_data)
        
        # Filter options
        col1, col2 = st.columns(2)
        with col1:
            table_filter = st.multiselect(
                "Filter by Table:",
                options=df['Table_Name'].unique(),
                default=df['Table_Name'].unique()
            )
        with col2:
            action_filter = st.multiselect(
                "Filter by Action:",
                options=df['Action'].unique(),
                default=df['Action'].unique()
            )
        
        # Apply filters
        filtered_df = df[
            (df['Table_Name'].isin(table_filter)) &
            (df['Action'].isin(action_filter))
        ]
        
        st.dataframe(filtered_df, use_container_width=True, hide_index=True)
        
        # Summary statistics
        st.subheader("📊 Audit Summary")
        col1, col2, col3 = st.columns(3)
        
        with col1:
            st.metric("Total Log Entries", len(df))
        with col2:
            st.metric("Tables Affected", df['Table_Name'].nunique())
        with col3:
            st.metric("Action Types", df['Action'].nunique())
    else:
        st.info("No audit log entries found")

# =============================================================
# FOOTER
# =============================================================
st.divider()
st.markdown("""
<div style='text-align: center; color: gray;'>
    <p>🏎 F1 Database Management System | Lab-09 Demonstration</p>
    <p>Developed for DBMS Mini Project</p>
</div>
""", unsafe_allow_html=True)
