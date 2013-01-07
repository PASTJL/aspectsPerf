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

import java.beans.PropertyVetoException;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import org.apache.commons.dbcp.BasicDataSource;

import com.mchange.v2.c3p0.ComboPooledDataSource;

public class MainDBCPAndC3P0test implements Runnable {
	public static BasicDataSource bds = null;
	static ComboPooledDataSource cpds = null;
	static {
		bds = new BasicDataSource();
		bds.setDriverClassName((String) ("com.mysql.jdbc.Driver"));
		bds.setUrl("jdbc:mysql://localhost:3306/javatest");
		bds.setUsername("javatest");
		bds.setPassword("javatest");
		bds.setInitialSize(5);
		bds.setMaxActive(20);
		cpds = new ComboPooledDataSource(false);
		try {
			cpds.setDriverClass("com.mysql.jdbc.Driver");
		} catch (PropertyVetoException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} // loads the jdbc driver
		cpds.setJdbcUrl("jdbc:mysql://localhost:3306/javatest");
		cpds.setUser("javatest");
		cpds.setPassword("javatest");
		// the settings below are optional --
		// c3p0 can work with defaults
		cpds.setMinPoolSize(5);
		cpds.setAcquireIncrement(5);
		cpds.setMaxPoolSize(20);
	}

	public boolean running = true;
	Thread thread = new Thread(this);

	public void run() {
		while (running) {
			Connection con = null;
			Statement stmt = null;
			ResultSet rs = null;
			Connection con1 = null;
			Statement stmt1 = null;
			ResultSet rs1 = null;
			try {

				con = bds.getConnection();

				stmt = con.createStatement();
				rs = stmt.executeQuery("SELECT * FROM javatest.testdata");

				con1 = cpds.getConnection();

				stmt1 = con1.createStatement();
				rs1 = stmt1.executeQuery("SELECT * FROM javatest.testdata");
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
				attemptClose(rs1);
				attemptClose(stmt1);
				attemptClose(con1);
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
		MainDBCPAndC3P0test[] tabRunners = new MainDBCPAndC3P0test[Integer
				.parseInt(args[0])];
		for (int i = 0; i < tabRunners.length; i++) {
			tabRunners[i] = new MainDBCPAndC3P0test();
			tabRunners[i].thread.start();
		}
	}
}
