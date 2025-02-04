import fs from 'fs/promises';
import _ from 'lodash';
import KcAdminClient from '@keycloak/keycloak-admin-client';
import retry from 'async-retry';

const config = {
  keycloak: {
    baseUrl: process.env.PLATFORM_URL + '/auth',
    username: process.env.KEYCLOAK_USERNAME,
    password: process.env.KEYCLOAK_PASSWORD,
    realm: {
      realm: 'horizon'
    },
    client: {
      clientId: 'gerrit',
      adminUrl: process.env.DOMAIN + '/',
      redirectUris: [process.env.DOMAIN + '/*'],
      protocol: 'openid-connect',
      publicClient: false
    },
    adminUser: {
      username: process.env.GERRIT_ADMIN_USERNAME,
      password: process.env.GERRIT_ADMIN_PASSWORD,
      firstName: 'Gerrit',
      lastName: 'Gerrit',
      email: 'gerrit@gerrit'
    }
  }
};

const keycloakAdmin = new KcAdminClient({
  baseUrl: config.keycloak.baseUrl
});

async function waitForKeycloak() {
  const opts = {
    retries: 100,
    minTimeout: 2000,
    factor: 1,
    onRetry: (err) => {console.info(`waiting for ${config.keycloak.baseUrl}...`, err.message)}
  };
  await retry(login, opts);
}

async function login()  {
  try {
    await keycloakAdmin.auth({
      'username': config.keycloak.username,
      'password': config.keycloak.password,
      'grantType': 'password',
      'clientId': 'admin-cli'
    });
  } catch (err) {
    throw err
  }
}

async function getRealm()  {
  try {
    let realm = await keycloakAdmin.realms.findOne({
      realm: config.keycloak.realm.realm,
    });
    keycloakAdmin.setConfig({
      realmName: realm.realm,
    });
    realm.keys = await keycloakAdmin.realms.getKeys({realm: realm.realm});
    config.keycloak.realm = realm;
  } catch (err) {
    throw err
  }
}

async function createClientIfRequired()  {
  try {
    let clients = await keycloakAdmin.clients.find();
    let client = _.find(clients, {clientId: config.keycloak.client.clientId});
    if (client) {
      console.info('updating %s client', config.keycloak.client.clientId);
      await keycloakAdmin.clients.update({id: client.id, realm: config.keycloak.realm.realm}, _.merge(client, config.keycloak.client));
    } else {
      console.info('creating %s client', config.keycloak.client.clientId);
      await keycloakAdmin.clients.create(config.keycloak.client);
    }
    clients = await keycloakAdmin.clients.find();
    client = _.find(clients, {clientId: config.keycloak.client.clientId});
    config.keycloak.client = client;
  } catch (err) {
    throw err
  }
}

async function createUserIfRequired()  {
  try {
    let users = await keycloakAdmin.users.find();
    let user = _.find(users, {username: config.keycloak.adminUser.username});
    
    if (user) {
      console.info('updating %s user', config.keycloak.adminUser.username);

      await keycloakAdmin.users.update({id: user.id}, 
      {
        username: config.keycloak.adminUser.username, 
        firstName: config.keycloak.adminUser.firstName,
        lastName: config.keycloak.adminUser.lastName,
        email: config.keycloak.adminUser.email
      });
    } else {
      console.info('creating %s user', config.keycloak.adminUser.username);

      const user = await keycloakAdmin.users.create({
        username: config.keycloak.adminUser.username,
        enabled: true,
        requiredActions: [],
        realm: config.keycloak.realm.realm,
        firstName: config.keycloak.adminUser.firstName,
        lastName: config.keycloak.adminUser.lastName,
        email: config.keycloak.adminUser.email
      });

      await keycloakAdmin.users.resetPassword({
        id: user.id,
        realm: config.keycloak.realm.realm,
        credential: {temporary: true, type: 'password', value: config.keycloak.adminUser.password}
      });
    }

  } catch (err) {
    throw err
  }
}

async function generateSecretFiles()  {
  try {
    let clients = await keycloakAdmin.clients.find();
    let client = _.find(clients, {clientId: config.keycloak.client.clientId});

    if (client) {
      console.info('dumping %s client data into json file', config.keycloak.client.clientId);
      fs.writeFile('client-gerrit.json', JSON.stringify(client));
    }

  } catch (err) {
    throw err
  }
}

async function configureKeycloak()  {
  try {
    await waitForKeycloak();
    await getRealm();
    await createClientIfRequired();
    await createUserIfRequired();
    await generateSecretFiles();
  } catch (err) {
    throw err
  }
}

configureKeycloak()
  .catch((err) => {
    console.error(err.message);
  });

