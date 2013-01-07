/*Copyright 2012 Jean-Louis PASTUREL 
 *
 *   Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 *   Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *   See the License for the specific language governing permissions and
 *  limitations under the License.
 */
package jlp.aspectj.test;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import org.apache.commons.dbcp.BasicDataSource;

public class MainDBCPtest implements Runnable {
	public static BasicDataSource bds = null;

	static {
		bds = new BasicDataSource();
		bds.setDriverClassName((String) ("com.mysql.jdbc.Driver"));
		bds.setUrl("jdbc:mysql://localhost:3306/javatest");
		bds.setUsername("javatest");
		bds.setPassword("javatest");
		bds.setInitialSize(5);
		bds.setMaxActive(20);

	}

	public boolean running = true;
	Thread thread = new Thread(this);

	public void run() {
		while (running) {
			Connection con = null;
			Statement stmt = null;
			ResultSet rs = null;
			try {

				con = bds.getConnection();

				stmt = con.createStatement();
				rs = stmt.executeQuery("SELECT * FROM javatest.testdata");
				Thread.sleep(100);
				// while (rs.next())
				// System.out.println(rs.getString(1));
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}

			catch (InterruptedException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} finally {
				// i try to be neurotic about ResourceManagement,
				// explicitly closing each resource
				// but if you are in the habit of only closing
				// parent resources (e.g. the Connection) and
				// letting them close their children, all
				// c3p0 DataSources will properly deal.
				attemptClose(rs);
				attemptClose(stmt);
				attemptClose(con);
			}
		}
	}

	static void attemptClose(ResultSet o) {
		try {
			if (o != null)
				o.close();
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	static void attemptClose(Statement o) {
		try {
			if (o != null)
				o.close();
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	static void attemptClose(Connection o) {
		try {
			if (o != null)
				o.close();
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	public static void main(String[] args) {
		// TODO Auto-generated method stub
		MainDBCPtest[] tabRunners = new MainDBCPtest[Integer.parseInt(args[0])];
		for (int i = 0; i < tabRunners.length; i++) {
			tabRunners[i] = new MainDBCPtest();
			tabRunners[i].thread.start();
		}
	}
}
