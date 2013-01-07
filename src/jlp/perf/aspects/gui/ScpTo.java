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
package jlp.perf.aspects.gui;

/* -*-mode:java; c-basic-offset:2; indent-tabs-mode:nil -*- */
import java.awt.Container;
import java.awt.GridBagConstraints;
import java.awt.Insets;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

import javax.swing.JPasswordField;
import javax.swing.JTextField;

import com.jcraft.jsch.Channel;
import com.jcraft.jsch.ChannelExec;
import com.jcraft.jsch.JSch;
import com.jcraft.jsch.Session;
import com.jcraft.jsch.UIKeyboardInteractive;
import com.jcraft.jsch.UserInfo;

public class ScpTo {
	public static void scpTo(String idCon, String file) {

		FileInputStream fis = null;
		try {

			String lfile1 = System.getProperty("workspace") + File.separator
					+ AspectsPackager.currentProject + File.separator + file;
			String user = AspectsPerf.hmAdresseAppli.get(idCon).user;

			String host = AspectsPerf.hmAdresseAppli.get(idCon).ipServeur;
			int port = Integer
					.parseInt(AspectsPerf.hmAdresseAppli.get(idCon).portIP);
			String rfile1 = "";

			if (AspectsPerf.hmAdresseAppli.get(idCon).type.equals("unix")) {
				if (!AspectsPerf.dirInstall.endsWith("/")) {
					rfile1 = AspectsPerf.dirInstall + "/" + file;
				} else {
					rfile1 = AspectsPerf.dirInstall + file;
				}
			}

			JSch jsch = new JSch();
			Session session = jsch.getSession(user, host, port);

			// username and password will be given via UserInfo interface.
			UserInfo ui = new MyUserInfo(idCon);
			session.setUserInfo(ui);
			session.connect();

			// exec 'scp -t rfile' remotely
			String command = "scp -p -t " + rfile1;
			Channel channel = session.openChannel("exec");
			((ChannelExec) channel).setCommand(command);

			// get I/O streams for remote scp
			OutputStream out = channel.getOutputStream();
			InputStream in = channel.getInputStream();

			channel.connect();

			if (checkAck(in) != 0) {
				System.exit(0);
			}

			// send "C0644 filesize filename", where filename should not include
			// '/'
			long filesize = (new File(lfile1)).length();
			command = "C0644 " + filesize + " ";
			if (lfile1.lastIndexOf('/') > 0) {
				command += lfile1.substring(lfile1.lastIndexOf('/') + 1);
			} else {
				command += lfile1;
			}
			command += "\n";
			out.write(command.getBytes());
			out.flush();

			if (checkAck(in) != 0) {
				System.exit(0);
			}

			// send a content of lfile
			fis = new FileInputStream(lfile1);
			byte[] buf = new byte[1024];
			while (true) {
				int len = fis.read(buf, 0, buf.length);
				if (len <= 0)
					break;
				out.write(buf, 0, len); // out.flush();
			}
			fis.close();
			fis = null;
			// send '\0'
			buf[0] = 0;
			out.write(buf, 0, 1);
			out.flush();
			if (checkAck(in) != 0) {
				System.exit(0);
			}
			out.close();

			channel.disconnect();
			session.disconnect();

		} catch (Exception e) {
			System.out.println(e);
			try {
				if (fis != null)
					fis.close();
			} catch (Exception ee) {
			}
		}
	}

	static int checkAck(InputStream in) throws IOException {
		int b = in.read();
		// b may be 0 for success,
		// 1 for error,
		// 2 for fatal error,
		// -1
		if (b == 0)
			return b;
		if (b == -1)
			return b;

		if (b == 1 || b == 2) {
			StringBuilder sb = new StringBuilder();
			int c;
			do {
				c = in.read();
				sb.append((char) c);
			} while (c != '\n');
			if (b == 1) { // error
				System.out.print(sb.toString());
			}
			if (b == 2) { // fatal error
				System.out.print(sb.toString());
			}
		}
		return b;
	}

	public static class MyUserInfo implements UserInfo, UIKeyboardInteractive {
		String idCon = "";

		public MyUserInfo(String idCon) {
			this.idCon = idCon;
		}

		public String getPassword() {
			return passwd;
		}

		public boolean promptYesNo(String str) {
			/*
			 * Object[] options={ "yes", "no" }; int
			 * foo=JOptionPane.showOptionDialog(null, str, "Warning",
			 * JOptionPane.DEFAULT_OPTION, JOptionPane.WARNING_MESSAGE, null,
			 * options, options[0]); return foo==0;
			 */
			return true;
		}

		String passwd;
		JTextField passwordField = (JTextField) new JPasswordField(20);

		public String getPassphrase() {
			return null;
		}

		public boolean promptPassphrase(String message) {
			return true;
		}

		public boolean promptPassword(String message) {
			passwd = AspectsPerf.hmAdresseAppli.get(idCon).passwd;
			System.out.println("password = " + passwd);
			return true;
		}

		public void showMessage(String message) {
			// JOptionPane.showMessageDialog(null, message);
			return;
		}

		final GridBagConstraints gbc = new GridBagConstraints(0, 0, 1, 1, 1, 1,
				GridBagConstraints.NORTHWEST, GridBagConstraints.NONE,
				new Insets(0, 0, 0, 0), 0, 0);
		private Container panel;

		public String[] promptKeyboardInteractive(String destination,
				String name, String instruction, String[] prompt, boolean[] echo) {

			return new String[] { AspectsPerf.hmAdresseAppli.get(idCon).passwd };
		}
	}
}
