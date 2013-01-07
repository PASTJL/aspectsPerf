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

import java.awt.Container;
import java.awt.GridBagConstraints;
import java.awt.Insets;
import java.io.InputStream;

import javax.swing.JPasswordField;
import javax.swing.JTextField;

import com.jcraft.jsch.Channel;
import com.jcraft.jsch.ChannelExec;
import com.jcraft.jsch.JSch;
import com.jcraft.jsch.Session;
import com.jcraft.jsch.UIKeyboardInteractive;
import com.jcraft.jsch.UserInfo;

public class ExecCommand {
	boolean file = true;

	public static String executeCommand(String idCon, String cmd) {
		String ret = "";
		try {

			JSch jsch = new JSch();

			String host = null;
			host = AspectsPerf.hmAdresseAppli.get(idCon).ipServeur;

			String user = AspectsPerf.hmAdresseAppli.get(idCon).user;
			int port = Integer
					.parseInt(AspectsPerf.hmAdresseAppli.get(idCon).portIP);

			Session session = jsch.getSession(user, host, port);

			// username and password will be given via UserInfo interface.
			UserInfo ui = new MyUserInfo(idCon);
			session.setUserInfo(ui);
			session.connect();

			System.out.println(" Exec command = " + cmd);
			Channel channel = session.openChannel("exec");
			((ChannelExec) channel).setCommand(cmd);

			channel.setInputStream(null);

			((ChannelExec) channel).setErrStream(System.err);

			InputStream in = channel.getInputStream();

			channel.connect();

			// byte[] tmp=new byte[1024];
			// Augmente pour pouvoir lister un plus grand nombre de fichiers
			// avec la commande ls
			byte[] tmp = new byte[102400];
			int j = 0;
			while (true) {
				while (in.available() > 0) {
					int i = in.read(tmp, j, 1024);
					// int i=in.read(tmp, j, 8);
					if (i < 0)
						break;
					// System.out.print(new String(tmp, j, j+i));
					j = j + i;
					ret = new String(tmp, 0, j);
				}
				if (channel.isClosed()) {
					// System.out.println("exit-status: "+channel.getExitStatus());
					break;
				}
				try {
					Thread.sleep(1000);
				} catch (Exception ee) {
				}
			}
			channel.disconnect();
			session.disconnect();
			System.out.println("Exec ret = " + ret);
			return ret;
		} catch (Exception e) {
			System.out.println(e);
		}
		return ret;
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
			 * options, options[0]);
			 */
			// repond toujours yes.
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
